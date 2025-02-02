This is effectively a clone of the "OklahomaAI-CLI" project also hosted by me.

It is a macOS/Swift CLI program that takes a single argument, a path to a folder, and runs all the *.JPG files it can find in that folder against a pre-trained ML model that will determine if the image does or does not contain a Raccoon.

The output is summarized in a raccoonNoRaccoon.json file.

The model has around 80% accuraccy. Almost all of those are false negatives - where it classifies a picture with a Raccoon as 0.NoRaccoon.
I use this to keep track of when Raccoons are active at our game feeders. Thus I prefer false negatives to false positives.

Enjoy!
