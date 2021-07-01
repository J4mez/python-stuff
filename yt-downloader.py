import pytube
import click

def init():

    link = input('Link vom Video: ')
    yt = pytube.YouTube(link)

    #Title of video
    print('Titel: ',yt.title)
    #Number of views of video
    print('Aufrufe: ',yt.views)
    if click.confirm('Ist dieses Video korrekt?', default=True):
            Auswahl(yt)
    else:
        init()
    
    
def Auswahl(yt):
    art = input('Audio oder Video? ')

    if art.lower() == 'audio' or art.lower() == 'a':
        print('Audio')
        Audio(yt)

    elif art.lower() == 'video' or art.lower() == 'v':
        print('Video')
        Video(yt)

    else:
        print('Unbekannte Art')
        Auswahl(yt)


def Audio(yt):
    stream = yt.streams.get_by_itag(140)
    stream.download()


def Video(yt):
    yt.streams.filter(progressive=False
    )
    print(yt)


init()