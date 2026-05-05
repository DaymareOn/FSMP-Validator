<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">

	<sch:title>hdtSMP64 configuration validation rules</sch:title>

	<sch:ns prefix="f" uri="FSMP-Validator"/>

	<sch:pattern id="invalid-physics-semantics">
		<sch:title>Physically invalid or dead configuration</sch:title>

		<!-- StiffSpring: minDistanceFactor > maxDistanceFactor causes inverted spring limits -->
		<sch:rule context="(f:stiffspring-constraint | f:stiffspring-constraint-default)[f:minDistanceFactor and f:maxDistanceFactor and number(f:minDistanceFactor) &gt; number(f:maxDistanceFactor)]">
			<sch:assert test="false()" role="error">minDistanceFactor is greater than maxDistanceFactor. The spring's minimum distance will exceed its maximum distance, causing the equilibrium point (a lerp between them) to fall outside the [min, max] range.</sch:assert>
		</sch:rule>

		<!-- ConeTwist: angularOnly is never read by readConeTwistConstraintTemplate -->
		<sch:rule context="(f:conetwist-constraint | f:conetwist-constraint-default)/f:angularOnly">
			<sch:assert test="false()" role="warning">angularOnly has no effect on conetwist-constraint: the current FSMP code (readConeTwistConstraintTemplate) does not handle this element — it is silently ignored at runtime.</sch:assert>
		</sch:rule>

		<!-- Static rigid body: gravity-factor and wind-factor have no effect (forces are not applied to kinematic/static bodies) -->
		<sch:rule context="f:gravity-factor[parent::f:bone-default[f:mass = '0'] or parent::f:bone[f:mass = '0']]">
			<sch:assert test="false()" role="warning">gravity-factor has no effect on a static rigid body (mass=0).</sch:assert>
		</sch:rule>
		<sch:rule context="f:wind-factor[parent::f:bone-default[f:mass = '0'] or parent::f:bone[f:mass = '0']]">
			<sch:assert test="false()" role="warning">wind-factor has no effect on a static rigid body (mass=0).</sch:assert>
		</sch:rule>

	</sch:pattern>

	<sch:pattern id="static-rigid-body">
		<sch:title>Static rigid body constraints (mass=0)</sch:title>

		<sch:rule context="f:inertia[parent::f:bone-default[f:mass = '0'] or parent::f:bone[f:mass = '0']]">
			<sch:assert test="false()" role="warning">inertia has no effect on a static rigid body (mass=0).</sch:assert>
		</sch:rule>
		<sch:rule context="f:linearDamping[parent::f:bone-default[f:mass = '0'] or parent::f:bone[f:mass = '0']]">
			<sch:assert test="false()" role="warning">linearDamping has no effect on a static rigid body (mass=0).</sch:assert>
		</sch:rule>
		<sch:rule context="f:angularDamping[parent::f:bone-default[f:mass = '0'] or parent::f:bone[f:mass = '0']]">
			<sch:assert test="false()" role="warning">angularDamping has no effect on a static rigid body (mass=0).</sch:assert>
		</sch:rule>
	</sch:pattern>

	<sch:pattern id="redundant-default-values">
		<sch:title>Elements set to their XSD default value (tag is unnecessary)</sch:title>

		<!-- #### bone and bone-default #### -->

		<sch:rule context="(f:bone | f:bone-default)/f:linearDamping[number(.) = 0]">
			<sch:assert test="false()" role="warning">linearDamping is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:bone | f:bone-default)/f:angularDamping[number(.) = 0]">
			<sch:assert test="false()" role="warning">angularDamping is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:bone | f:bone-default)/f:gravity-factor[number(.) = 1]">
			<sch:assert test="false()" role="warning">gravity-factor is set to its default value (1). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:bone | f:bone-default)/f:wind-factor[number(.) = 1]">
			<sch:assert test="false()" role="warning">wind-factor is set to its default value (1). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:bone | f:bone-default)/f:friction[number(.) = 0.5]">
			<sch:assert test="false()" role="warning">friction is set to its default value (0.5). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:bone | f:bone-default)/f:rollingFriction[number(.) = 0]">
			<sch:assert test="false()" role="warning">rollingFriction is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:bone | f:bone-default)/f:restitution[number(.) = 0]">
			<sch:assert test="false()" role="warning">restitution is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:bone | f:bone-default)/f:margin-multiplier[number(.) = 1]">
			<sch:assert test="false()" role="warning">margin-multiplier is set to its default value (1). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:bone | f:bone-default)/f:collision-filter[number(.) = 0]">
			<sch:assert test="false()" role="warning">collision-filter is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:bone | f:bone-default)/f:inertia[number(@x) = 0 and number(@y) = 0 and number(@z) = 0]">
			<sch:assert test="false()" role="warning">inertia is set to its default value (x=0, y=0, z=0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>

		<!-- #### per-triangle-shape and per-vertex-shape #### -->

		<sch:rule context="(f:per-triangle-shape | f:per-vertex-shape)/f:margin[number(.) = 1]">
			<sch:assert test="false()" role="warning">margin is set to its default value (1). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:per-triangle-shape/f:penetration[number(.) = 1]">
			<sch:assert test="false()" role="warning">penetration is set to its default value (1). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:per-triangle-shape/f:prenetration[number(.) = 1]">
			<sch:assert test="false()" role="warning">prenetration is set to its default value (1). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:per-triangle-shape | f:per-vertex-shape)/f:shared[normalize-space(.) = 'public']">
			<sch:assert test="false()" role="warning">shared is set to its default value ("public"). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>

		<!-- #### shape (bone collider) #### -->

		<sch:rule context="f:shape/f:margin[number(.) = 0]">
			<sch:assert test="false()" role="warning">margin is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:shape/f:radius[number(.) = 0]">
			<sch:assert test="false()" role="warning">radius is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:shape/f:height[number(.) = 0]">
			<sch:assert test="false()" role="warning">height is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>

		<!-- #### stiffspring-constraint and stiffspring-constraint-default #### -->

		<sch:rule context="(f:stiffspring-constraint | f:stiffspring-constraint-default)/f:stiffness[number(.) = 0]">
			<sch:assert test="false()" role="warning">stiffness is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:stiffspring-constraint | f:stiffspring-constraint-default)/f:damping[number(.) = 0]">
			<sch:assert test="false()" role="warning">damping is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:stiffspring-constraint | f:stiffspring-constraint-default)/f:equilibrium[number(.) = 0.5]">
			<sch:assert test="false()" role="warning">equilibrium is set to its default value (0.5). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:stiffspring-constraint | f:stiffspring-constraint-default)/f:minDistanceFactor[number(.) = 1]">
			<sch:assert test="false()" role="warning">minDistanceFactor is set to its default value (1). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:stiffspring-constraint | f:stiffspring-constraint-default)/f:maxDistanceFactor[number(.) = 1]">
			<sch:assert test="false()" role="warning">maxDistanceFactor is set to its default value (1). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>

		<!-- #### conetwist-constraint and conetwist-constraint-default #### -->

		<sch:rule context="(f:conetwist-constraint | f:conetwist-constraint-default)/f:angularOnly[normalize-space(.) = 'false' or normalize-space(.) = '0']">
			<sch:assert test="false()" role="warning">angularOnly is set to its default value (false). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:conetwist-constraint | f:conetwist-constraint-default)/f:biasFactor[number(.) = 0.3]">
			<sch:assert test="false()" role="warning">biasFactor is set to its default value (0.3). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:conetwist-constraint | f:conetwist-constraint-default)/f:coneLimit[number(.) = 0]">
			<sch:assert test="false()" role="warning">coneLimit is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:conetwist-constraint | f:conetwist-constraint-default)/f:limitSoftness[number(.) = 1]">
			<sch:assert test="false()" role="warning">limitSoftness is set to its default value (1). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:conetwist-constraint | f:conetwist-constraint-default)/f:limitX[number(.) = 0]">
			<sch:assert test="false()" role="warning">limitX is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:conetwist-constraint | f:conetwist-constraint-default)/f:limitY[number(.) = 0]">
			<sch:assert test="false()" role="warning">limitY is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:conetwist-constraint | f:conetwist-constraint-default)/f:limitZ[number(.) = 0]">
			<sch:assert test="false()" role="warning">limitZ is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:conetwist-constraint | f:conetwist-constraint-default)/f:planeLimit[number(.) = 0]">
			<sch:assert test="false()" role="warning">planeLimit is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:conetwist-constraint | f:conetwist-constraint-default)/f:relaxationFactor[number(.) = 1]">
			<sch:assert test="false()" role="warning">relaxationFactor is set to its default value (1). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:conetwist-constraint | f:conetwist-constraint-default)/f:swingSpan1[number(.) = 0]">
			<sch:assert test="false()" role="warning">swingSpan1 is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:conetwist-constraint | f:conetwist-constraint-default)/f:swingSpan2[number(.) = 0]">
			<sch:assert test="false()" role="warning">swingSpan2 is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:conetwist-constraint | f:conetwist-constraint-default)/f:twistLimit[number(.) = 0]">
			<sch:assert test="false()" role="warning">twistLimit is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:conetwist-constraint | f:conetwist-constraint-default)/f:twistSpan[number(.) = 0]">
			<sch:assert test="false()" role="warning">twistSpan is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>

		<!-- #### generic-constraint and generic-constraint-default #### -->

		<sch:rule context="(f:generic-constraint | f:generic-constraint-default)/f:angularServoMotors[normalize-space(.) = 'false' or normalize-space(.) = '0']">
			<sch:assert test="false()" role="warning">angularServoMotors is set to its default value (false). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:generic-constraint | f:generic-constraint-default)/f:angularStiffnessLimited[normalize-space(.) = 'true' or normalize-space(.) = '1']">
			<sch:assert test="false()" role="warning">angularStiffnessLimited is set to its default value (true). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:generic-constraint | f:generic-constraint-default)/f:enableAngularSprings[normalize-space(.) = 'true' or normalize-space(.) = '1']">
			<sch:assert test="false()" role="warning">enableAngularSprings is set to its default value (true). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:generic-constraint | f:generic-constraint-default)/f:enableLinearSprings[normalize-space(.) = 'true' or normalize-space(.) = '1']">
			<sch:assert test="false()" role="warning">enableLinearSprings is set to its default value (true). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:generic-constraint | f:generic-constraint-default)/f:linearServoMotors[normalize-space(.) = 'false' or normalize-space(.) = '0']">
			<sch:assert test="false()" role="warning">linearServoMotors is set to its default value (false). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:generic-constraint | f:generic-constraint-default)/f:linearStiffnessLimited[normalize-space(.) = 'true' or normalize-space(.) = '1']">
			<sch:assert test="false()" role="warning">linearStiffnessLimited is set to its default value (true). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:generic-constraint | f:generic-constraint-default)/f:springDampingLimited[normalize-space(.) = 'true' or normalize-space(.) = '1']">
			<sch:assert test="false()" role="warning">springDampingLimited is set to its default value (true). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:generic-constraint | f:generic-constraint-default)/f:useLinearReferenceFrameA[normalize-space(.) = 'false' or normalize-space(.) = '0']">
			<sch:assert test="false()" role="warning">useLinearReferenceFrameA is set to its default value (false). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:generic-constraint | f:generic-constraint-default)/f:motorCFM[number(.) = 0]">
			<sch:assert test="false()" role="warning">motorCFM is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:generic-constraint | f:generic-constraint-default)/f:motorERP[number(.) = 0.9]">
			<sch:assert test="false()" role="warning">motorERP is set to its default value (0.9). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:generic-constraint | f:generic-constraint-default)/f:stopCFM[number(.) = 0]">
			<sch:assert test="false()" role="warning">stopCFM is set to its default value (0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:generic-constraint | f:generic-constraint-default)/f:stopERP[number(.) = 0.2]">
			<sch:assert test="false()" role="warning">stopERP is set to its default value (0.2). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>

		<!-- #### Vector3 elements (compared via @x, @y, @z attributes) #### -->

		<sch:rule context="f:angularBounce[number(@x) = 0 and number(@y) = 0 and number(@z) = 0]">
			<sch:assert test="false()" role="warning">angularBounce is set to its default value (x=0, y=0, z=0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:angularLowerLimit[number(@x) = 1 and number(@y) = 1 and number(@z) = 1]">
			<sch:assert test="false()" role="warning">angularLowerLimit is set to its default value (x=1, y=1, z=1). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:angularUpperLimit[number(@x) = -1 and number(@y) = -1 and number(@z) = -1]">
			<sch:assert test="false()" role="warning">angularUpperLimit is set to its default value (x=-1, y=-1, z=-1). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:angularStiffness[number(@x) = 0 and number(@y) = 0 and number(@z) = 0]">
			<sch:assert test="false()" role="warning">angularStiffness is set to its default value (x=0, y=0, z=0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:angularSpringFrequency[number(@x) = 0.25 and number(@y) = 0.25 and number(@z) = 0.25]">
			<sch:assert test="false()" role="warning">angularSpringFrequency is set to its default value (x=0.25, y=0.25, z=0.25). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:angularNonHookeanDamping[number(@x) = 0 and number(@y) = 0 and number(@z) = 0]">
			<sch:assert test="false()" role="warning">angularNonHookeanDamping is set to its default value (x=0, y=0, z=0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:angularNonHookeanStiffness[number(@x) = 0 and number(@y) = 0 and number(@z) = 0]">
			<sch:assert test="false()" role="warning">angularNonHookeanStiffness is set to its default value (x=0, y=0, z=0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:linearBounce[number(@x) = 0 and number(@y) = 0 and number(@z) = 0]">
			<sch:assert test="false()" role="warning">linearBounce is set to its default value (x=0, y=0, z=0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:linearLowerLimit[number(@x) = 1 and number(@y) = 1 and number(@z) = 1]">
			<sch:assert test="false()" role="warning">linearLowerLimit is set to its default value (x=1, y=1, z=1). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:linearUpperLimit[number(@x) = -1 and number(@y) = -1 and number(@z) = -1]">
			<sch:assert test="false()" role="warning">linearUpperLimit is set to its default value (x=-1, y=-1, z=-1). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:linearStiffness[number(@x) = 0 and number(@y) = 0 and number(@z) = 0]">
			<sch:assert test="false()" role="warning">linearStiffness is set to its default value (x=0, y=0, z=0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:linearSpringFrequency[number(@x) = 0.25 and number(@y) = 0.25 and number(@z) = 0.25]">
			<sch:assert test="false()" role="warning">linearSpringFrequency is set to its default value (x=0.25, y=0.25, z=0.25). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:linearNonHookeanDamping[number(@x) = 0 and number(@y) = 0 and number(@z) = 0]">
			<sch:assert test="false()" role="warning">linearNonHookeanDamping is set to its default value (x=0, y=0, z=0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:linearNonHookeanStiffness[number(@x) = 0 and number(@y) = 0 and number(@z) = 0]">
			<sch:assert test="false()" role="warning">linearNonHookeanStiffness is set to its default value (x=0, y=0, z=0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>

		<!-- #### generic-constraint bool motors (default false) #### -->

		<sch:rule context="(f:generic-constraint | f:generic-constraint-default)/f:linearMotors[normalize-space(.) = 'false' or normalize-space(.) = '0']">
			<sch:assert test="false()" role="warning">linearMotors is set to its default value (false). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="(f:generic-constraint | f:generic-constraint-default)/f:angularMotors[normalize-space(.) = 'false' or normalize-space(.) = '0']">
			<sch:assert test="false()" role="warning">angularMotors is set to its default value (false). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>

		<!-- #### Vector3 elements with default (0,0,0) not yet covered above #### -->

		<sch:rule context="f:linearEquilibrium[number(@x) = 0 and number(@y) = 0 and number(@z) = 0]">
			<sch:assert test="false()" role="warning">linearEquilibrium is set to its default value (x=0, y=0, z=0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:angularEquilibrium[number(@x) = 0 and number(@y) = 0 and number(@z) = 0]">
			<sch:assert test="false()" role="warning">angularEquilibrium is set to its default value (x=0, y=0, z=0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:linearMaxMotorForce[number(@x) = 0 and number(@y) = 0 and number(@z) = 0]">
			<sch:assert test="false()" role="warning">linearMaxMotorForce is set to its default value (x=0, y=0, z=0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:angularMaxMotorForce[number(@x) = 0 and number(@y) = 0 and number(@z) = 0]">
			<sch:assert test="false()" role="warning">angularMaxMotorForce is set to its default value (x=0, y=0, z=0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:linearTargetVelocity[number(@x) = 0 and number(@y) = 0 and number(@z) = 0]">
			<sch:assert test="false()" role="warning">linearTargetVelocity is set to its default value (x=0, y=0, z=0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>
		<sch:rule context="f:angularTargetVelocity[number(@x) = 0 and number(@y) = 0 and number(@z) = 0]">
			<sch:assert test="false()" role="warning">angularTargetVelocity is set to its default value (x=0, y=0, z=0). This tag is unnecessary and can be removed.</sch:assert>
		</sch:rule>

	<sch:pattern id="range-constraints">
		<sch:title>Numeric range constraints for factor [0,1] and posFloat [>=0] types</sch:title>

		<!-- Normalise comma-as-decimal-separator before comparing.
		     translate(., ',', '.') converts "0,5" -> "0.5" so number() works correctly. -->

		<!-- factor elements: must be in [0, 1] -->
		<sch:rule context="f:angularDamping | f:biasFactor | f:equilibrium | f:gravity-factor | f:limitSoftness | f:linearDamping | f:motorERP | f:relaxationFactor | f:stopERP">
			<sch:let name="v" value="number(translate(., ',', '.'))"/>
			<sch:assert test="$v &gt;= 0 and $v &lt;= 1" role="error"><sch:name/> value '<sch:value-of select="."/>' is out of range: must be in [0, 1].</sch:assert>
		</sch:rule>

		<!-- posFloat elements: must be >= 0 -->
		<sch:rule context="f:coneLimit | f:damping | f:friction | f:wind-factor | f:limitX | f:limitY | f:limitZ | f:margin | f:margin-multiplier | f:mass | f:maxDistanceFactor | f:minDistanceFactor | f:motorCFM | f:planeLimit | f:radius | f:height | f:rollingFriction | f:stiffness | f:stopCFM | f:swingSpan1 | f:swingSpan2 | f:twistLimit | f:twistSpan">
			<sch:let name="v" value="number(translate(., ',', '.'))"/>
			<sch:assert test="$v &gt;= 0" role="error"><sch:name/> value '<sch:value-of select="."/>' is out of range: must be non-negative (>= 0).</sch:assert>
		</sch:rule>

	</sch:pattern>

</sch:schema>
