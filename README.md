# HackIllinois

HackIllinois 2016 Submission - John Cenify
Team: Richard Su, University of Iowa

Description: John Cenify is an iOS app that encourages users to bring out their inner John Cena by getting angry. Upon following the prompts, the user will take a picture of him/herself or another person’s face. After having the “anger level” determined, the user will be told to get even more angry if the score is low or showed a video of the internet-viral John Cena meme as a reward. The user can repeat this as many times as he/she desires.

More in-depth description: The app runs on iOS and was written in Swift. The main feature is the emotion recognition provided by Microsoft’s Project Oxford. Once the user selects the photo to use, it is converted from a UIImage to a base-64-encoded string. This string is uploaded via AlamoFire (an HTTP networking library) to be hosted on Imgur. Once online, AlamoFire is used again to take the image and determine the emotion levels of the face within the image. Finally, the anger score is taken from the output and thresholded to either display the video with congratulatory words or encouragement to make a more “angry” face. This can be repeated up to 10000 times per day, restricted by Microsoft’s quota for requests to the emotion API as well as my lack of money to fund excess requests.
