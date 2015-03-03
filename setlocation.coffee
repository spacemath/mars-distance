# InSight lander and impact site
lander = $blab.lander  #;
impact = $blab.impact  #;

# Set locations of lander and impact site.
# Edit and press shift-enter.
lander.pos -129.6, 5.4  #;
impact.pos -10.8, 36  #;

# Calculate and display distance.
$blab.distance(
    lander.x, lander.y
    impact.x, impact.y
)

