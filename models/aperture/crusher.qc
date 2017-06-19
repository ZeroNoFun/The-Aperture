// Created by Crowbar 0.33.0.0

$ModelName "aperture/crusher.mdl"

$BodyGroup "default"
{
	studio "crusher_reference.smd"
}

$LOD 50
{
	replacemodel "crusher_reference.smd" "crusher_model_lod1.smd"
}
$LOD 100
{
	replacemodel "crusher_reference.smd" "crusher_model_lod2.smd"
}

$SurfaceProp "default"

$Contents "solid"

$MaxEyeDeflection 90

$CDMaterials ""

$Attachment "base_attach" "base_Zrot" 0 -47.83 -0.12 rotate 0 0 0

$CBox 0 0 0 0 0 0

$BBox -642.154 -96 -248.561 129.41 96 0


$SectionFrames 30 199

$Sequence "BindPose" {
	"crusher_anims\BindPose.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$Sequence "smash_idle" {
	"crusher_anims\smash_idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "smash_out" {
	"crusher_anims\smash_out.smd"
	{ event AE_CL_PLAYSOUND 16 "World.CrusherSeparate" }
	{ event AE_CL_PLAYSOUND 4 "World.CrusherOpen" }
	{ event AE_CL_PLAYSOUND 58 "World.RobotImpactLgCrusher" }
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "smash_fast" {
	"crusher_anims\smash_fast.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$Sequence "smash_out_idle" {
	"crusher_anims\smash_out_idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "smash_big" {
	"crusher_anims\smash_big.smd"
	{ event AE_CL_PLAYSOUND 56 "World.CrusherSeparateBig" }
	{ event AE_CL_PLAYSOUND 40 "World.CrusherOpenBig" }
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "wall_smashA" {
	"crusher_anims\wall_smashA.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$Sequence "wall_smashA_idle" {
	"crusher_anims\wall_smashA_idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$Sequence "smash_in" {
	"crusher_anims\smash_in.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$collisionmodel			"crusher_reference_phys.smd" { 
	$concave
	$mass 40
	$maxconvexpieces 1000
}

$KeyValues
{
}
