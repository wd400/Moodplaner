from datetime import datetime
import asyncio
import librosa
from threading import Thread
from blacksheep.server import Application
from blacksheep.messages import Response
from blacksheep.server.responses import FileInput, text,file,ContentDispositionType
from blacksheep.server.bindings import FromForm, FromHeader, FromFiles,FromJSON
import psycopg2
from psycopg2.extras import Json
from blacksheep.server.responses import json
from dataclasses import dataclass
import json as js
import re
import os
import music_tag
import hashlib
from secrets import token_urlsafe
from logic import METRICS, buildPlaylistRAW,measureSongRAW
#uvicorn api:app --port 5000 --reload


#fais la paix avec toi même
#check str lengths
#rebuild quand login
#fonction checkupdate
#TODO: crossplatform

def getConnection():
    return psycopg2.connect(user="postgres",
                                password="postgres",
                                host="127.0.0.1",
                                port="5432",
                                database="moodplaner")
connection = getConnection()


ENABLED_EXTENSIONS=[
  'OGG',
  'OGA',
  'OGX',
  'AAC',
  'M4A',
  'MP3',
  'WMA',
  'WAV',
  'FLAC',
  'OPUS',
]



cursor= connection.cursor()
cursor.execute(open("default.sql", "r").read())
connection.commit()
cursor.close()

app = Application()

@dataclass
class LogData:
    mail: str
    password: str


def effectivemetrics(allmetrics):
    result={}

    def mergemetrics(userdefined:dict,computerdefined:dict):
        for metric in userdefined.keys():
            if userdefined[metric][1]:
                computerdefined[metric]=userdefined[metric][0]
        return computerdefined

    for row in allmetrics:
        result[row[0]]=mergemetrics(row[1],row[2])
        result[row[0]]['duration']=row[3]
    return result



async def buildPlaylist(generatorId:str,accountId:int):
    
    cursor = connection.cursor()
    cursor.execute("SELECT a.musicid, a.metrics,b.computedmetrics,b.duration FROM usermusics as a, musiccollection as b where a.musicid=b.musicid and a.account=%s",(accountId,))
    allmetrics=cursor.fetchall()
    data=effectivemetrics(allmetrics)

    cursor.execute("SELECT metrics from generators where account=%s and id=%s",(accountId,generatorId))
    metrics=cursor.fetchone()[0]

    tracks=buildPlaylistRAW(data,metrics)

    cursor.execute("INSERT INTO playlists (account,title,musicids) VALUES (%(accountId)s,(SELECT title || ' ' || CURRENT_TIMESTAMP(0) from generators where id=%(generatorId)s and account=%(accountId)s ) ,%(tracks)s)",
    {'accountId':accountId,
    'generatorId':generatorId,
    'tracks':tracks
    })
    connection.commit()
    cursor.close()

async def measureSong(musicId:str,X,sr):
    #metricCode,value
    measures,step_size=measureSongRAW(X,sr)

    cursor = connection.cursor()
    cursor.execute("UPDATE musiccollection SET computedmetrics = %s,step_size=%s where musicid = %s ;",
      (  Json(measures),
      step_size,
            musicId))
    connection.commit()
    cursor.close()
    

@app.route("/signup",methods=['POST'])
async def singnup(input: FromForm[LogData]):
    if not re.match("([a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+)", input.value.mail):
        return Response(408)
    if not re.match("(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9])(?=.{8,})",input.value.password):
        return Response(407)
    
    cursor = connection.cursor()
    cursor.execute("SELECT COUNT(id) FROM USERS")
    nbUsers=cursor.fetchone()[0]
    if nbUsers>=100:
        cursor.close()
        return Response(410)
    cursor.execute("SELECT exists (SELECT 1 FROM users WHERE mail = %s LIMIT 1);",(input.value.mail,))
    if cursor.fetchone()[0]:
        cursor.close()
        return Response(409)
    cursor.execute("INSERT INTO users (mail,hashpass) VALUES (%s,%s) returning id",(input.value.mail,  hashlib.new('sha512',input.value.password.encode()).hexdigest()  ))
    accountId=str(cursor.fetchone()[0])
    connection.commit()
    cursor.close()

    os.makedirs(accountId,exist_ok=True)

    return Response(201)


@app.route("/version",methods=['GET'])
async def version():
    return text(open('version').readline())




@app.route("/login",methods=['POST'])
async def login(input: FromForm[LogData]):
    if not re.match("([a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+)", input.value.mail):
        return Response(408)
    if not re.match("(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9])(?=.{8,})",input.value.password):
        return Response(407)
    
    cursor = connection.cursor()
    cursor.execute("SELECT id FROM users WHERE mail = %s AND hashpass = %s LIMIT 1;",(input.value.mail, hashlib.new('sha512',input.value.password.encode()).hexdigest() ))
    accountId=cursor.fetchone()
    if accountId is None:
        cursor.close()
        return Response(409)
    token=token_urlsafe(50)
    cursor.execute("INSERT INTO tokens (token,account) VALUES (%s,%s);",(token,accountId))
    connection.commit()
    cursor.close()
    return text(token)


class FromAcceptHeader(FromHeader[str]):
    name = "token"

@dataclass
class ListData:
    listData: list


@dataclass
class SyncData:
    setData: set
    lastSync: str

@dataclass
class SetData:
    setData: set

def accountFromToken(token:str):
    cursor = connection.cursor()
    cursor.execute("update tokens set lastmodified = ((now())::timestamp without time zone) where token = %s returning account",(token,))
    accountId=cursor.fetchone()
    connection.commit()
    cursor.close()
    return accountId

@app.route("/syncplaylists",methods=['POST'])
async def syncplaylists(input:FromForm[SyncData],auth:FromAcceptHeader):
    accountId=accountFromToken(auth.value)
    if accountId is None:
        return Response(403)
    cursor = connection.cursor()
    syncDate=datetime.now()
    responsedata={'time':syncDate.isoformat(),'playlists':[],'error':''}
    cursor.execute("""SELECT id,lastmodified FROM playlists where account = %s and lastmodified>%s ;""",(accountId,datetime.fromisoformat(input.value.lastSync))) 
    onServer= dict(cursor.fetchall())
    print("onServer",onServer)
    def addToResponse(playlistId:int):
            cursor.execute("""SELECT id,title,musicids,lastmodified FROM playlists where account = %s and id = %s ;""",(accountId,playlistId)) 
            result = cursor.fetchone()
            newPlaylist={}
            newPlaylist['id']=result[0]
            newPlaylist['title']=result[1]
            newPlaylist['tracks']=result[2]
            newPlaylist['lastmodified']=result[3].isoformat()
            
            responsedata["playlists"].append(newPlaylist)

    for playlistattribs in js.loads(input.value.setData):
        print("generatorattribs",playlistattribs)
        try:
            playlistId=playlistattribs['playlistId']
            playlistName=playlistattribs['playlistName']
            tracks=playlistattribs['tracks']
            todel=playlistattribs['todel']
            lastModif=datetime.fromisoformat(playlistattribs['lastModif'])
  #          lastSync=datetime.fromisoformat(generatorattribs['lastSync'])
        except:
            cursor.close()
            return Response(401)
        if type(tracks)!=list or type(todel)!=bool:
            cursor.close()
            return Response(402)   
        if playlistId in onServer.keys():
            print(lastModif)
            print(onServer[playlistId])
            if lastModif<   onServer[playlistId]:
                #rajouter à responsedata
                print("serveur plus recent")
                addToResponse(playlistId)
            else:
                #update
                if todel:
                    cursor.execute("""DELETE FROM playlists WHERE account = %s and id = %s ;""",(accountId,playlistId))
                else:
                    print("sur le tel plus recent")
                    cursor.execute("""UPDATE playlists set lastmodified =%s,title=%s,musicids=%s where account = %s and id= %s;""",
                (lastModif,playlistName,tracks,accountId,playlistId) )
            onServer.pop(playlistId)
            
        else:
            if todel:
                print("on le del")
                cursor.execute("""DELETE FROM playlists WHERE account = %s and id = %s ;""",(accountId,playlistId))

                
            else:
                print("on l'ajoute car existe pas!")

                cursor.execute("""
                do $$
                begin
                IF ((SELECT count(id) FROM playlists where account=%(accountId)s)<100) or exists (SELECT 1 FROM playlists WHERE id = %(playlistId)s LIMIT 1) THEN
                    INSERT INTO playlists (lastmodified,title,musicids,account,id) VALUES (%(lastModif)s,%(playlistName)s,%(tracks)s,%(accountId)s,%(playlistId)s) ON CONFLICT ON CONSTRAINT playlists_pkey DO UPDATE SET musicids=%(tracks)s,title=%(playlistName)s;
                END IF;
                end
                $$""",{'accountId':accountId,'playlistId':playlistId,'lastModif':lastModif,'playlistName':playlistName,'tracks':tracks})
                if cursor.rowcount==0:
                    responsedata['error']+=f'\n{playlistName} not synced'


#                 cursor.execute("""INSERT INTO playlists (lastmodified,title,musicids,account,id) VALUES (%(lastModif)s,%(playlistName)s,%(tracks)s,%(accountId)s,%(playlistId)s) ON CONFLICT ON CONSTRAINT playlists_pkey DO UPDATE 
#   SET musicids=%(tracks)s,title=%(playlistName)s;""",
#            {     "lastModif":lastModif,
#                 "playlistName":playlistName,
#                 "tracks":tracks,
#                 "accountId":accountId,
#                 "playlistId":playlistId} )
        

    for generatorId in onServer:
        print("pas considere",generatorId)
        addToResponse(generatorId)

    connection.commit()
    cursor.close()
    print("réponse synctrack",responsedata)
    return json(responsedata)



@app.route("/synctracks",methods=['POST'])
async def synctracks(input:FromForm[SetData],auth:FromAcceptHeader):
    accountId=accountFromToken(auth.value)
    if accountId is None:
        return Response(403)
    cursor = connection.cursor()
    responsedata=[]
    for track in js.loads(input.value.setData):
        hash,todel=list(track)
        todel=bool(todel)
        
        if todel:
            print("want to be deleted",hash)
            #TODO ALSO DELETE collectionmusic (if)
            cursor.execute("DELETE FROM usermusics WHERE account = %s and musicid = %s;",(accountId,hash))
            connection.commit()
            cursor.execute("""DELETE FROM musiccollection a WHERE a.musicid=%s and NOT EXISTS (
                            SELECT FROM usermusics b
                            WHERE  a.musicid = b.musicid and a.musicid = %s
                          );""",(hash,hash))
            if cursor.rowcount>0:
                os.remove(hash)
        else:
            cursor.execute("SELECT exists (SELECT 1 FROM usermusics WHERE account = %s and musicid = %s LIMIT 1);",(accountId,hash))
            if not cursor.fetchone()[0]:
                responsedata.append(hash)

    connection.commit()
    cursor.close()
    return json(responsedata)


@app.route("/synctrack",methods=['POST'])
async def synctrack(files: FromFiles,auth:FromAcceptHeader):
    accountId=accountFromToken(auth.value)
    if accountId is None:
        return Response(403)
    if files is None or files.value is None or len(files.value) != 1:
        return Response(400)

    file = files.value[0]
    if file.file_name.decode().split('.')[-1].upper() not in ENABLED_EXTENSIONS:
        return Response(401)

    if len(file.data) > 15_000_000:
        return Response(402)

    hash = hashlib.new('sha256',file.data).hexdigest()

    
    
  #  filePath=os.path.join(str(accountId[0]),hash)
    filePath=os.path.join("songs", hash)

    tmpTitle=''
    try:
        tmpTitle=music_tag.load_file(filePath)['title'].value
    except:
        pass
    if tmpTitle=='':
        tmpTitle=file.name.decode()

    cursor = connection.cursor()
    cursor.execute("SELECT computedmetrics FROM musiccollection WHERE musicid = %s ;",(hash,))
    if cursor.rowcount>0:
        computedmetrics=cursor.fetchone()[0]
        cursor.execute("""INSERT INTO usermusics (musicid,account,title,metrics) VALUES (%(musicId)s,%(accountId)s,%(title)s,%(usermetrics)s) ON CONFLICT ON CONSTRAINT musics_pkey DO UPDATE SET title=%(title)s;""",
        {'accountId':accountId,'musicId':hash,'title':tmpTitle,'usermetrics':Json(computedmetrics)}
        )
        connection.commit()
        cursor.close()
        return Response(200)

    with open(filePath, "wb") as f:
        f.write(file.data)
    try:
        print(filePath)
        
        y, sr = librosa.load(filePath)
 #       tempo, beats = librosa.beat.beat_track(y=y, sr=sr)
    except:
       # os.remove(filePath)
        return Response(404)
    
    measures,step_size=measureSongRAW(y,sr)
    duration = librosa.get_duration(y=y, sr=sr)



    
    #si déjà dedans:ok
    #sinon
    #s
    print(Json({k: [v,False] for k, v in measures.items()}))
    

    # cursor.execute("INSERT INTO musiccollection (musicid,fixedmetrics,othermetrics) VALUES (%s,%s,%s) ON CONFLICT DO NOTHING",(hash,Json({'bpm':tempo}),Json({'duration':duration})))

    # #musicid,metrics,duration,ver
    # cursor.execute("INSERT INTO usermusics (musicid,account,title) VALUES (%s,%s,%s) ON CONFLICT ON CONSTRAINT musics_pkey DO UPDATE SET title=%s",(hash,accountId,tmpTitle,tmpTitle))
    cursor.execute("""
    do $$
    begin
    IF ((SELECT count(musicid) FROM usermusics where account=%(accountId)s)<(SELECT accounttype from users where id=%(accountId)s)*10000) or  exists (SELECT 1 FROM usermusics WHERE musicid = %(musicId)s LIMIT 1) THEN
    INSERT INTO musiccollection (musicid,duration,computedmetrics,step_size,enginever) VALUES (%(musicId)s,%(duration)s,%(measures)s,%(step_size)s,%(version)s) ON CONFLICT DO NOTHING;
    INSERT INTO usermusics (musicid,account,title,metrics) VALUES (%(musicId)s,%(accountId)s,%(title)s,%(usermetrics)s) ON CONFLICT ON CONSTRAINT musics_pkey DO UPDATE SET title=%(title)s;
    END IF;
    end
    $$
""",{'accountId':accountId,'version':1,'musicId':hash,'duration':duration,'title':tmpTitle,'usermetrics':Json({k: [v,False] for k, v in measures.items()}),'measures':Json(measures),'step_size':step_size})
    
    connection.commit()
    cursor.close()
    print("synctrack done")
   # thread = Thread(target=asyncio.run, args=(measureSong(hash,y,sr),))
   # thread.daemon = True
   # thread.start()

    return Response(200)


@app.route("/syncgenerators",methods=['POST'])
async def syncgenerators(input:FromForm[SyncData],auth:FromAcceptHeader):
    accountId=accountFromToken(auth.value)
    if accountId is None:
        return Response(403)
    cursor = connection.cursor()
    syncDate=datetime.now()
    added=0
    responsedata={'time':syncDate.isoformat(),'generators':[],'error':''}
    cursor.execute("""SELECT id,lastmodified FROM generators where account = %s and lastmodified>%s ;""",(accountId,datetime.fromisoformat(input.value.lastSync))) 
    onServer= dict(cursor.fetchall())
    print("onServer",onServer)
    print("onServer",onServer)
    def addToResponse(generatorId:int):
            cursor.execute("""SELECT id,title,metrics,lastmodified FROM generators where account = %s and id = %s ;""",(accountId,generatorId)) 
            result = cursor.fetchone()
            newGenerator={}
            newGenerator['id']=result[0]
            newGenerator['title']=result[1]
            newGenerator['metrics']=result[2]
            newGenerator['lastmodified']=result[3].isoformat()
            
            responsedata["generators"].append(newGenerator)

    for generatorattribs in js.loads(input.value.setData):
        print("generatorattribs",generatorattribs)
        try:
            generatorId=generatorattribs['generatorId']
            generatorName=generatorattribs['generatorName']
            measures=generatorattribs['measures']
            todel=generatorattribs['todel']
            lastModif=datetime.fromisoformat(generatorattribs['lastModif'])
  #          lastSync=datetime.fromisoformat(generatorattribs['lastSync'])
        except:
            cursor.close()
            return Response(401)
        if type(measures)!=dict or type(todel)!=bool:
            cursor.close()
            return Response(402)   
        if generatorId in onServer.keys():
            print(lastModif)
            print(onServer[generatorId])
            if lastModif< onServer[generatorId]:
                #rajouter à responsedata
                print("serveur plus recent")
                addToResponse(generatorId)
            else:
                #update
                if todel:
                    cursor.execute("""DELETE FROM generators WHERE account = %s and id = %s ;""",(accountId,generatorId))
                else:
                    print("sur le tel plus recent")
                    cursor.execute("""UPDATE generators set lastmodified =%s,title=%s,metrics=%s where account = %s and id= %s;""",
                (lastModif,generatorName,Json(measures),accountId,generatorId) )
            onServer.pop(generatorId)
            
        else:
            if todel:
                print("on le del")
                cursor.execute("""DELETE FROM generators WHERE account = %s and id = %s ;""",(accountId,generatorId))
            else:
                cursor.execute("""
                do $$
                begin
                IF ((SELECT count(id) FROM generators where account=%(accountId)s)<100) or exists (SELECT 1 FROM generators WHERE id = %(generatorId)s LIMIT 1) THEN
                    INSERT INTO generators (lastmodified,title,metrics,account,id) VALUES (%(lastModif)s,%(generatorName)s,%(measures)s,%(accountId)s,%(generatorId)s) ON CONFLICT ON CONSTRAINT generators_pkey DO UPDATE 
  SET metrics=%(measures)s,title=%(generatorName)s;
                END IF;
                end
                $$
                """,{'accountId':accountId,'generatorId':generatorId,'lastModif':lastModif,'generatorName':generatorName,'measures':Json(measures)})
                if cursor.rowcount==0:
                    responsedata['error']+=f'\n{generatorName} not synced'
                    
                
#                     cursor.execute("""INSERT INTO generators (lastmodified,title,metrics,account,id) VALUES (%(lastModif)s,%(generatorName)s,%(measures)s,%(accountId)s,%(generatorId)s) ON CONFLICT ON CONSTRAINT generators_pkey DO UPDATE 
#   SET metrics=%(measures)s,title=%(generatorName)s;""",
#            {     "lastModif":lastModif,
#                 "generatorName":generatorName,
#                 "measures":Json(measures),
#                 "accountId":accountId,
#                 "generatorId":generatorId} )
#                     added+=1

        

    for generatorId in onServer:
        print("pas considere",generatorId)
        addToResponse(generatorId)

    connection.commit()
    cursor.close()
    return json(responsedata)


@app.route("/getmetrics/:musicid",methods=['GET'])
async def getmetrics(musicid,auth:FromAcceptHeader):
    accountId=accountFromToken(auth.value)
    if accountId is None:
        return Response(403)
    cursor = connection.cursor()
    cursor.execute("SELECT a.metrics,b.computedmetrics,b.enginever,b.step_size,b.duration FROM usermusics as a, musiccollection as b WHERE  a.account = %s and a.musicid = %s and a.musicid=b.musicid;",(accountId,musicid))
    result=cursor.fetchone()
    if result:
        return json({'usermetrics':result[0],'default':result[1],'version':result[2],'duration':result[4],'step':result[3]})
    else:
        return Response(400)

@dataclass
class MetricUpdate:
    musicId: str
    data: dict


def boolJson2Python(text:str):
    if text=='true':
        return True
    if text=='false':
        return False
    return None

@app.route("/uploadmetric/",methods=['POST'])
async def uploadmetric(inputForm:FromForm[MetricUpdate],auth:FromAcceptHeader):
    accountId=accountFromToken(auth.value)
    if accountId is None:
        return Response(403)
    #check: bonne taille/bon format/bon id de metriques
    final=js.loads(inputForm.value.data)
    for metricId in final:
        print('metricId',metricId)
        if metricId not in METRICS:
            return Response(402)
        current=final[metricId]
        if len(current) != 2:
            return Response(403)
        #TODO: if len(current[0])!=nb of values return err
        if type(current[1])!=bool:
            return Response(404)
        if type(current[0])!=list:
            for v in current[0]:
                if type(v) not in (int,float):
                    return Response(405)
    

    cursor = connection.cursor()
    #jsonb_set(metrics, %s , %s, false)
    cursor.execute("UPDATE usermusics SET metrics = %s where account = %s and musicid = %s returning true;",
   ( Json(final),
    accountId,
    inputForm.value.musicId))



    connection.commit()
    if cursor.fetchone()[0]:

        return Response(200)
    else:
        return Response(400)

@app.route("/generate/{generatorId}",methods=['GET'])
async def generate(generatorId:int,auth:FromAcceptHeader):
    accountId=accountFromToken(auth.value)
    if accountId is None:
        return Response(403)
    
    
    thread = Thread(target=asyncio.run, args=(buildPlaylist(generatorId,accountId),))
    thread.daemon = True
    thread.start()
    return Response(200)


@app.route("/songs/{musicId}",methods=['GET'])
async def generate(musicId:str,auth:FromAcceptHeader):
    accountId=accountFromToken(auth.value)
    if accountId is None:
        return Response(403)
    req=file(
        os.path.join("songs",musicId),
        "Content-Type: audio/mpeg",
        content_disposition=ContentDispositionType.ATTACHMENT,
    )
    print(req)
    print(req.headers)
    print(dir(req))
    return req


@app.route("/ping",methods=['GET'])
async def ping(auth:FromAcceptHeader):
    accountId=accountFromToken(auth.value)
    if accountId is None:
        return Response(403)
    return Response(200)


@dataclass
class QueryData:
    query: str


@app.route("/search",methods=['POST'])
async def ping(input:FromForm[QueryData],auth:FromAcceptHeader):
    accountId=accountFromToken(auth.value)
    if accountId is None:
        return Response(403)
    cursor = connection.cursor()
    cursor.execute('SELECT musicid,title from usermusics where title ilike %s and account = %s',('%'+input.value.query+'%' ,accountId))
    result=[]
    tmp=cursor.fetchone()
    while tmp:
        result.append({'hash':tmp[0],'title':tmp[1]})
        tmp=cursor.fetchone()
    return json(result)

@app.route("/delete",methods=['GET'])
async def ping(auth:FromAcceptHeader):
    accountId=accountFromToken(auth.value)
    if accountId is None:
        return Response(403)
    cursor = connection.cursor()
    cursor.execute('DELETE FROM usermusics where account = %s',(accountId,))
    cursor.execute('DELETE FROM playlists where account = %s',(accountId,))
    cursor.execute('DELETE FROM generators where account = %s',(accountId,))
    cursor.execute('DELETE FROM tokens where account = %s',(accountId,))
    cursor.execute('DELETE FROM users where id = %s',(accountId,))

    connection.commit()
    cursor.execute("""DELETE FROM musiccollection a WHERE NOT EXISTS (
                            SELECT FROM usermusics b
                            WHERE  a.musicid = b.musicid
                          ) RETURNING a.musicid;""")

    hashs=cursor.fetchall()
    connection.commit()
    cursor.close()
    for hash in hashs:
        os.remove(os.path.join("songs", hash[0]))
    return Response(200)


