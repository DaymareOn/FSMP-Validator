<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">

	<sch:title>hdtSMP64 configuration validation rules</sch:title>

	<sch:ns prefix="f" uri="FSMP-Validator"/>

	<sch:pattern id="static-rigid-body">
		<sch:title>Static rigid body constraints (mass=0)</sch:title>

		<sch:rule context="f:inertia[parent::f:bone-default[f:mass = '0'] or parent::f:bone[f:mass = '0']]">
			<sch:assert test="false()" role="error">inertia has no effect on a static rigid body (mass=0) and must not be used when mass is 0.</sch:assert>
		</sch:rule>
		<sch:rule context="f:linearDamping[parent::f:bone-default[f:mass = '0'] or parent::f:bone[f:mass = '0']]">
			<sch:assert test="false()" role="error">linearDamping has no effect on a static rigid body (mass=0) and must not be used when mass is 0.</sch:assert>
		</sch:rule>
		<sch:rule context="f:angularDamping[parent::f:bone-default[f:mass = '0'] or parent::f:bone[f:mass = '0']]">
			<sch:assert test="false()" role="error">angularDamping has no effect on a static rigid body (mass=0) and must not be used when mass is 0.</sch:assert>
		</sch:rule>
	</sch:pattern>

</sch:schema>
