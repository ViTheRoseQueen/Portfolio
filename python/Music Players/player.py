from pygame import mixer

mixer.init() # Start the mixer

mixer.music.load("song.mp3") # Load the song
mixer.music.set_volume(0.7) # Set the volume
mixer.music.play() # Play the mixer

while True:
    print("Press 'p' to pause 'r' to resume")
    print("Press 'e' to exit the program")
    query = input(">>> ")

    if query == 'p':
        mixer.music.pause() # Pause Music

    elif query == 'r':
        mixer.music.unpause() # Resume Music

    elif query == 'e':
        mixer.music.stop() # Stop the mixer
        break
