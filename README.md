# Starship Invasion

# TODO
- level 4
	- race track
	- add random/triggered explosions
- space walk audio:
	- of alerting when asteroids are coming
	- impact of asteroids

## Maybe
- space warrior: special of throwing grenade?

## Exporting
- maps scaled up to: 4x

## Movies
ffmpeg -r 60 -f image2 -s 1280x720 -i overmind/recorded_game%08d.png -vcodec libx264 -crf 15 -pix_fmt yuv420p recorded_game.mp4
ffmpeg -i recorded_game.mp4 -q:v 10 -q:a 10 recorded_game.ogv
SET clip=
ffmpeg -i %clip%.mp4 -q:v 10 -q:a 10 %clip%.ogv
