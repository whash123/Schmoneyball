# Schmoneyball

## Intro

An R shiny app to help your local soccer club manage their transfers and identify high quality targets! You can find the live working app here to check out:
https://whash123.shinyapps.io/finalproject/

As one of my first DS projects, the main premise of this app was to find a way to weed through tons of data from the mid 2010s on Europe's elite soccer stars. Similar to Billy Bean's "Moneyball" in baseball, we wanted to see if there was a way to start sifting through data in soccer to highlight some players that people wouldn't normally look at.

Much of scouting in soccer is very context and visually-focused, with many scouts preferring attributes that don't always reflect as success in the data, so we thought we could give light to some players that the analytics love, in order to help your team hire the next undiscovered gem!



## Process

### 1) Data Scraping
To do this, we used packages in R, namely 'rvest' 'XML' and 'xml2', to scrape 2 years of data from 1500 players between Europe's Big 5 Leagues (England' Premier League, Spain's La Liga, Italy's Serie A, Germany's Bundesliga, and France's Ligue 1), and some additional teams that played in European competitions.

We chose to take as many important match attributes as could be readily available for as many players as possible, which meant finding the intersection of available data for each league. Certain leagues did not have the same technologies, so data that uses more advanced tracking technology (kilometres ran, sprint speed, etc.) could not be aggregated for every league, and was thus ignored.



### 2) Data Munging

This part was particularly troubling, as there were a lot of inconsistencies in the data across time for some players and teams, as well as normalizing the data so that we can compare player's stats across time periods, league difficuly, and, most importantly, minutes / games played.

The inconsistencies took a lot of manual functions, mutate calls, and error handling making sure we could match all the data up together and keep everything consistent. We also had to use some tricks to find every position every player could play, and spread out to priority of favorite positions (max of 3). This was not too difficult, but more of a longer, manual process to deal with the unique issues of this data we scraped.

For the actual player statistics we scraped, we decided to normalize the vast majority of data points to the *per 90 minutes played* level. In soccer, 90 minutes is the length of a normal full-length game, so it is the standard metric to compare stats, allowing us to control for how much a player played, while also giving context to how successful we could expect that player to be in a game. Some certain stats, like pass accuracy, we normalized to show the variance about a mean of 1. We chose a range of 1-2 and a mean of 1 so that we would never get players with negative overall scores, but the effect was still the same as a -1 to 1 fitted distribution.



### 3) Function Creating

Now that we have the data normalized so we can compare players, we need to build some functions so we can get down to some of the main characteristics of players that managers would want. Instead of sorting players by *Number of times dispossed*, which only tells one part of the story, people might want to be looking for the best dribbling wingers. To do this, we need to come up with some formulas to use these data in a more meaningful way.

We created 8 player archetypes that would be most appealing and are generalizations of the key aspects of some players around the pitch. These were:
* Crosser
* Creator
* Finisher
* Controller
* Dribbler
* Breakup Play
* Tackler
* Sweeper

Each ones of these is a mix of these normalized data points we created, weighting for the most important attributes to become that kind of player on the field. For instance, a good dribbler would have a high number of successful dribbles but a low number of times disposessed (someone takes the ball off them while they are dribbling). The best sweeper may have a good mix of tackles, interceptions, aerial duel win percentage, and long passes out from the back.

Now that we have these calculations in, with ages and positions, we should have everything we need to build an interactive dashboard so you can find the best players that you are looking for! Whether that be an experienced midfielder specializing in breaking up play and holding up the ball, a young direct dribbling winger, etc.



### 4) Dashboard Building

To build this dashboard, we needed to have 2 pieces:

1. The App

The App was fairly straightforward, offering you an age slider, a set of player archetypes you can look for, and a selector box for positions you may be interested in. No matter what archetype you select, you will see a few tabs for the players that come up as the best for the inputs you selected.

* A "Basic" tab with information on the player (team, nationality, positions, etc.)
* A "Defending" tab with normalized data on the defending sides of the ball
* A "Passing" tab giving you more information on how they succeed in the passing game
* An "Attacking" tab that details the player's performance in the final third
* A "Feature" tab that gives you the calculation for the selected archetype you chose. This is the sorted table that all the other tabs are also sorted by, showing the top performer in the metric you want to look at!

2. The Server

Once we had all the data we needed and a simple interface from the App, the Server was fairly straightforward - all we need to do is subset the original datafile to include only the players that meet your input criteria (age and position), score each of these on the archetype you are looking for, and return everything to the App on the front-end so you can have a look!

# Conclusion

While we do not have transfer market values yet, this is all you need to look around and see which players fit the mold for what your team is missing! Have some fun and play around and see if there is anything that can improve your favorite team.

Credits to Tatiana Santos, my team partner in building this, as we finished by winning the Data Science speaker performance at the iXperience Session 2 Keynote.
