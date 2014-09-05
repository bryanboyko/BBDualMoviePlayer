#Overview
After implementing video with MPMoviePlayer, I assumed it would be easy to effectively repeat the same code and create two MPMoviePlayers running simultaneously while side by side on the same screen. It turns out that MPMoviePlayer can only play one video at a time. However, it is possible to run two videos simultaneously using AVFoundation and AVPlayers. This application implements a custom view class converted to AVPlayer to play two videos simultaneously.

NOTE: The goal was to achive basic functionality and not to make a beautiful double movie player. In a later version i will add more effective and aesthetic controls to the movie players.

#Reflection
Initially the goal was to write code that could play two videos simultaneously on different threads. Unfortunately, UI can only be updated by the main thread, so it seems that while it may be possible to play a movie on a background thread (say the application is in the background) it is not possible to have a movie that is playing on screen while running on a background thread. (If anybody knows how to do this I would love to know!). Ultimately though, two videos playing on the same screen with AVPlayers appear to run seamlessly, meaning that there is no need to run one video on a background thread. If other operations needed to be performed while the movies were playing, they could be run on a background thread.

#Preview
![alt tag](https://github.com/bryanboyko/BBDualMoviePlayer/blob/master/BBDualMoviePlayer.PNG)
