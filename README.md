# Starship Invasion

# TODO
- level 4:
	- add random/triggered explosions
- cinematics:
	- when you start game, it shows a tutorial / cinematic
	- when game ends, it shows cinematic
	- level 3 add cinematic of setting bomb

## Maybe
- space warrior: special of throwing grenade?

## Exporting
- maps scaled up to: 4x

## Movies
ffmpeg -r 60 -f image2 -s 1280x720 -i overmind/recorded_game%08d.png -vcodec libx264 -crf 15 -pix_fmt yuv420p recorded_game.mp4
ffmpeg -i recorded_game.mp4 -q:v 10 -q:a 10 recorded_game.ogv
SET clip=
ffmpeg -i %clip%.mp4 -q:v 10 -q:a 10 %clip%.ogv
