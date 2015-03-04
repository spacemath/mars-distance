$blab.noGitHubRibbon = true;

new $blab.Canvas((canvas) -> 
	objects = new $blab.LanderAndImpact(canvas)
	$blab.lander = objects.lander
	$blab.impact = objects.impact
)