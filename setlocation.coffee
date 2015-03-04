# InSight lander and impact site
lander = $blab.lander  #;
impact = $blab.impact  #;

# Set locations of lander and impact site.
# Edit then press shift-enter or swipe right.
lander.pos -135, 3  #;
impact.pos -10.8, 36  #;

# Calculate and display distance.
$blab.distance(
    lander.x, lander.y
    impact.x, impact.y
)
