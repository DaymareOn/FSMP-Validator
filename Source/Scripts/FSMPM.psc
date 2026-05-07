Scriptname FSMPM extends SKI_ConfigBase
import MiscUtil
import JsonUtil
import JMap

FSMPMPlayerScript Property FSMPM_PlayerScript Auto

int configMapId = 0
bool bSMPOn = true

string configFilePath = "Data/SKSE/Plugins/hdtSkinnedMeshConfigs/configs.xml"
string presetFolder = "Data/SKSE/Plugins/hdtSkinnedMeshConfigs/configsPresets"
String sLabelCommands = "Commands"
String sLabelLogs = "Logs"
String sLabelSimplification = "Simplification"
String sLabelQuality = "Performance"
String sLabelWind = "Wind "; WIND seems to be a papyrus keyword...
String sLabelPresets = "Presets "; presets seems to be a lowercase papyrus keyword...
String sLabelValidation = "Validation "
String sLabelClickMe
String sLabelLoaded
String sLastLoadedPresetName = ""
bool bLastTagFound = true
String[] keys
String[] defaultValues
int[] presetsInt
string[] presetsFiles

int startIndex = 0
bool bDependenciesOK = false
string sMissingDependencies = ""

int Function GetVersion()
	Return 302
EndFunction

; #################################################################################################
; #################################################################################################
; Events 
; #################################################################################################
; #################################################################################################

Event OnConfigInit()
	initConfig()
	bDependenciesOK = checkDependencies()
	if (!bDependenciesOK)
		Debug.Notification("FSMP MCM: missing " + sMissingDependencies + ". Menu disabled.")
		return
	endif
	initMap()
	loadConfigFile(configFilePath)

	bool currentPresetMatches = sLastLoadedPresetName != "" && configMatchesPreset(presetFolder + "/" + sLastLoadedPresetName)
	if (!currentPresetMatches)
		if (configMatchesPreset(presetFolder + "/Default.xml"))
			sLastLoadedPresetName = "Default.xml"
		else
			sLastLoadedPresetName = ""
		endif
	endif

	; This one is to sanitize the config file.
	storeConfigAndSmpReset()
EndEvent

bool Function checkDependencies()
	sMissingDependencies = ""
	int testId = JMap.object()
	if (testId == 0)
		sMissingDependencies = "JContainers"
	endif
	string[] testArr = PapyrusUtil.StringArray(1)
	if (testArr.Length == 0)
		if (sMissingDependencies != "")
			sMissingDependencies += " and "
		endif
		sMissingDependencies += "PapyrusUtil SE"
	endif
	return sMissingDependencies == ""
EndFunction

event OnVersionUpdate(int NewVersion)
	if (NewVersion >= 302 && CurrentVersion < 302)
		initConfig()
		sLastLoadedPresetName = ""
		Debug.Notification("FSMP MCM updated to version 3.0.2.")
	endif
endEvent

event OnGameReload()
	parent.OnGameReload() ; This calls OnConfigInit() and all necessary events to register the MCM, but only once during first install
	bSMPOn = true
	self.OnConfigInit()
endEvent

Event OnPageReset(String aPage)
	if (!bDependenciesOK)
		UnloadCustomContent()
		SetTitleText("FSMP: Missing Dependencies")
		AddHeaderOption("Required dependencies not detected")
		AddTextOption("Missing: " + sMissingDependencies, "", OPTION_FLAG_DISABLED)
		AddTextOption("Install and restart Skyrim", "", OPTION_FLAG_DISABLED)
		return
	endif
	if (aPage == "")
		LoadCustomContent("FSMP/Logo.dds")
		return
	endif
	UnloadCustomContent()

	SetTitleText(aPage)
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	If (aPage == sLabelCommands)
		AddHeaderOption("Master switch")
		AddToggleOptionST("ToggleSMP", "smp on", bSMPOn)
		SetCursorPosition(1)
		AddHeaderOption("Console commands")
		AddTextOptionST("SMP", "smp ", sLabelClickMe)
		AddTextOptionST("SMPReset", "smp reset", sLabelClickMe)
		AddTextOptionST("SMPList", "smp list", sLabelClickMe)
		AddTextOptionST("SMPDetail", "smp detail", sLabelClickMe)
		AddTextOptionST("SMPDumptree", "smp dumptree", sLabelClickMe)
		AddTextOptionST("SMPQueryOverride", "smp QueryOverride", sLabelClickMe)
		AddTextOptionST("SMPValidate", "smp validate", sLabelClickMe)
		AddTextOptionST("SMPValidateGear", "smp validate gear", sLabelClickMe)
	ElseIf (aPage == sLabelSimplification)
		AddHeaderOption("Disabling some SMP")
		AddToggleOptionST("ToggleSMPHairWhenWigEquipped", "Disable SMP hair when there's a wig", JMap.getStr(configMapId, "disableSMPHairWhenWigEquipped", "") == "true")
		AddToggleOptionST("Toggle1stPersonViewPhysics", "No SMP for your PC when in 1st person view", JMap.getStr(configMapId, "disable1stPersonViewPhysics", "") == "true")
		;AddToggleOptionST("ToggleNPCFaceParts", "Enable NPC face parts", JMap.getStr(configMapId, "enableNPCFaceParts", "") == "true")
		AddEmptyOption()
		AddHeaderOption("Enabling nearest NPCs")
		AddSliderOptionST("SliderMinCullingDistance", "SMP is always on below this distance", JMap.getStr(configMapId, "minCullingDistance", 300) as float, "{0}")
		SetCursorPosition(1)
		AddHeaderOption("Disabling SMP NPCs")
		bool autoAdjust = JMap.getStr(configMapId, "autoAdjustMaxSkeletons", "") == "true"
		int autoAdjustOptionsFlag = 0
		if (!autoAdjust)
			autoAdjustOptionsFlag = 1
		endif
		AddSliderOptionST("SliderMaxSkeletons", "Maximum SMP NPC number", JMap.getStr(configMapId, "maximumActiveSkeletons", 40) as float, "{0}")
		AddToggleOptionST("ToggleAutoAdjustMaxSkeletons", "Auto adjust the max number of SMP NPCs", autoAdjust)
		AddSliderOptionST("SliderTimeFrameBudget", "Allowed frame time budget for SMP (ms)", JMap.getStr(configMapId, "budgetMs", 3.5) as float, "{1}", autoAdjustOptionsFlag)
		AddSliderOptionST("SliderSampleSize", "Adjustment speed", JMap.getStr(configMapId, "sampleSize", 5) as float, "{0}", autoAdjustOptionsFlag)
	ElseIf (aPage == sLabelQuality)
		AddHeaderOption("Simulation quality")
		AddSliderOptionST("SliderNumIterations", "Simulation quality", JMap.getStr(configMapId, "numIterations", 16) as float)
		AddSliderOptionST("SliderERP", "ERP ", JMap.getStr(configMapId, "erp", 0.2) as float, "{2}")
		AddEmptyOption()
		AddHeaderOption("Simulation frequency and slowdowns")
		AddToggleOptionST("ToggleRealTime", "Use your real time", JMap.getStr(configMapId, "useRealTime", "") == "true")
		AddSliderOptionST("SliderMinFPS", "Simulation frequency", JMap.getStr(configMapId, "min-fps", 60) as float)
		AddSliderOptionST("SliderMaxSubsteps", "Slowdowns adjustment", JMap.getStr(configMapId, "maxSubSteps", 2) as float)
		SetCursorPosition(1)
		AddHeaderOption("Limitations")
		bool clampRotations = JMap.getStr(configMapId, "clampRotations", "") == "true"
		int clampRotationsOptionsFlag = OPTION_FLAG_NONE
		int clampedResetsOptionFlag = OPTION_FLAG_NONE
		if (clampRotations)
			clampedResetsOptionFlag = OPTION_FLAG_DISABLED
		else
			clampRotationsOptionsFlag = OPTION_FLAG_DISABLED
		endif
		bool clampedResets = JMap.getStr(configMapId, "unclampedResets", "") == "true"
		int unclampedResetAngleOptionFlag = OPTION_FLAG_NONE
		if (!clampedResets || clampRotations)
			unclampedResetAngleOptionFlag = OPTION_FLAG_DISABLED
		endif
		AddToggleOptionST("ToggleClampRotations", "Limit rotations", clampRotations)
		AddSliderOptionST("SliderRotationSpeedLimit", "Rotation speed limit", JMap.getStr(configMapId, "rotationSpeedLimit", 10) as float, "{1}", clampRotationsOptionsFlag)
		AddToggleOptionST("ToggleClampedResets", "Reset SMP when rotation speed isn't limited", clampedResets, clampedResetsOptionFlag)
		AddSliderOptionST("SliderUnclampedResetAngle", "Angle at which the reset occurs", JMap.getStr(configMapId, "unclampedResetAngle", 120) as float, "{0}", unclampedResetAngleOptionFlag)
		AddEmptyOption()
	ElseIf (aPage == sLabelWind)
		bool enableWind = JMap.getStr(configMapId, "enabled", "") == "true"
		int enableWindOptionsFlag = OPTION_FLAG_NONE
		if (!enableWind)
			enableWindOptionsFlag = OPTION_FLAG_DISABLED
		endif
		AddToggleOptionST("ToggleWind", "Enable FSMP-native wind", enableWind)
		AddSliderOptionST("SliderWindStrength", "Wind strength", JMap.getStr(configMapId, "windStrength", 2.0) as float, "{1}", enableWindOptionsFlag)
		AddSliderOptionST("SliderNoWindDistance", "Distance for no wind", JMap.getStr(configMapId, "distanceForNoWind", 50.0) as float, "{0}", enableWindOptionsFlag)
		AddSliderOptionST("SliderMaxWindDistance", "Distance for max wind", JMap.getStr(configMapId, "distanceForMaxWind", 2500.0) as float, "{0}", enableWindOptionsFlag)
	ElseIf (aPage == sLabelValidation)
		bool validationEnabled = JMap.getStr(configMapId, "validationEnabled", "") == "true"
		int validationOptionsFlag = OPTION_FLAG_NONE
		if (!validationEnabled)
			validationOptionsFlag = OPTION_FLAG_DISABLED
		endif
		AddToggleOptionST("ToggleValidationEnabled", "Run FSMP validator at startup", validationEnabled)
		AddSliderOptionST("SliderWarnTriangleCount", "Triangle count warning threshold", JMap.getStr(configMapId, "warn-triangle-count", "10000") as float, "{0}", validationOptionsFlag)
		AddEmptyOption()
		SetCursorPosition(1)
		AddHeaderOption("Output folder")
		string outputDir = JMap.getStr(configMapId, "output-dir", "")
		AddInputOptionST("InputOutputDir", "Improved files output folder", outputDir, validationOptionsFlag)
	ElseIf (aPage == sLabelLogs)
		AddSliderOptionST("SliderLog", "Choose your log level", JMap.getStr(configMapId, "logLevel", 0) as float)
	ElseIf (aPage == sLabelPresets)
		AddHeaderOption("Load preset")
		presetsFiles = MiscUtil.FilesInFolder(presetFolder, "xml")
		int index = 0
		While (index < presetsFiles.Length && index < presetsInt.Length)
			string presetFile = presetsFiles[index]
			if (sLastLoadedPresetName == presetFile)
				presetsInt[index] = AddTextOption(presetFile, sLabelLoaded, OPTION_FLAG_DISABLED)
			else
				presetsInt[index] = AddTextOption(presetFile, sLabelClickMe, OPTION_FLAG_NONE)
			endif
			index += 1
		EndWhile
		While (index < presetsInt.Length)
			presetsInt[index] = 0
			index += 1
		EndWhile
	Else
		SetTitleText("Faster Skinned Mesh Physics")
	EndIf
EndEvent

Event OnOptionSelect(int a_option)
	int presetFileIndex = -1
	int index = 0
	While (index < presetsFiles.Length && index < presetsInt.Length)
		if (presetsInt[index] != 0 && presetsInt[index] == a_option) ; found
			presetFileIndex = index
		endif
		index += 1
	EndWhile
	
	if (presetFileIndex != -1)
		string presetName = presetsFiles[presetFileIndex]
		if (loadConfigFile(presetFolder + "/" + presetName))
			sLastLoadedPresetName = presetName
		else
			sLastLoadedPresetName = ""
		endif
		storeConfigAndSmpReset()
		ForcePageReset()
	endif
EndEvent

Event OnOptionHighlight(int a_option)
	SetInfoText("Click on the preset, it takes several seconds")
EndEvent

; #################################################################################################
; #################################################################################################
; Functions
; #################################################################################################
; #################################################################################################

function initConfig()
	ModName = "FSMP"

	; Initializing here to ensure that the strings are updated on existing saves
	sLabelCommands = "Commands"
	sLabelLogs = "Logs"
	sLabelSimplification = "Simplification"
	sLabelQuality = "Performance"
	sLabelValidation = "Validation "
	sLabelWind = "Wind "; WIND seems to be a papyrus keyword...
	sLabelPresets = "Presets "; presets seems to be a lowercase papyrus keyword...
	sLabelClickMe = "Click me!"
	sLabelLoaded = "Loaded!"


	Pages = new String[9]
	Pages[0] = sLabelSimplification
	Pages[1] = sLabelQuality
	Pages[2] = sLabelWind
	Pages[3] = sLabelValidation
	Pages[4] = sLabelLogs
	Pages[5] = ""
	Pages[6] = sLabelCommands
	Pages[7] = ""
	Pages[8] = sLabelPresets

	keys = new String[23]
	keys[0] = "logLevel"; first serie
	keys[1] = "enableNPCFaceParts"; unused by FSMP...
	keys[2] = "disableSMPHairWhenWigEquipped"
	keys[3] = "clampRotations"
	keys[4] = "rotationSpeedLimit"
	keys[5] = "unclampedResets"
	keys[6] = "unclampedResetAngle"
	keys[7] = "useRealTime"
	keys[8] = "minCullingDistance"
	keys[9] = "autoAdjustMaxSkeletons"
	keys[10] = "maximumActiveSkeletons"
	keys[11] = "budgetMs"
	keys[12] = "sampleSize"
	keys[13] = "disable1stPersonViewPhysics"
	keys[14] = "numIterations"; second serie
	keys[15] = "groupEnableMLCP"; unused by FSMP...
	keys[16] = "erp"
	keys[17] = "min-fps"
	keys[18] = "maxSubSteps"
	keys[19] = "enabled"; third serie
	keys[20] = "windStrength"
	keys[21] = "distanceForNoWind"
	keys[22] = "distanceForMaxWind"

	defaultValues = new String[23]
	defaultValues[0] = "0"; first serie
	defaultValues[1] = "true"; unused by FSMP...
	defaultValues[2] = "true"
	defaultValues[3] = "true"
	defaultValues[4] = "10"
	defaultValues[5] = "true"
	defaultValues[6] = "130"
	defaultValues[7] = "true"
	defaultValues[8] = "300"
	defaultValues[9] = "true"
	defaultValues[10] = "10"
	defaultValues[11] = "3.5"
	defaultValues[12] = "5"
	defaultValues[13] = "false"
	defaultValues[14] = "10"; second serie
	defaultValues[15] = "false"; unused by FSMP...
	defaultValues[16] = "0.2"
	defaultValues[17] = "60"
	defaultValues[18] = "2"
	defaultValues[19] = "true"; third serie
	defaultValues[20] = "2.0"
	defaultValues[21] = "50.0"
	defaultValues[22] = "2500"

	presetsInt = new int[50]
endfunction

; Initialize the map with default values
Function initMap()
	configMapId = JMap.object()
	; We never release this object, we keep it in the savegame.
	JValue.retain(configMapId, "FSMP MCM")

	int index = 0
	While (index < keys.Length)
		JMap.setStr(configMapId, keys[index], defaultValues[index])
		index += 1
	EndWhile

	; Validation settings — separate JMap keys to avoid collision with wind's "enabled"
	JMap.setStr(configMapId, "validationEnabled", "true")
	JMap.setStr(configMapId, "warn-triangle-count", "10000")
	JMap.setStr(configMapId, "output-dir", "")
EndFunction

; Initialize the map with config file values
bool function loadConfigFile(string path)
	startIndex = 0
	string sConfig = MiscUtil.ReadFromFile(path)
	if (sConfig == "")
		return false
	endif

	int index = 0
	bool allFound = true
	While (index < keys.Length)
		string tag = keys[index]
		string value = getTagValue(tag, sConfig, true, true)
		if (!bLastTagFound)
			allFound = false
		endif
		JMap.setStr(configMapId, tag, value)
		index += 1
	EndWhile

	loadValidationSection(sConfig)
	return allFound
endfunction

; Load the <validation> section into dedicated JMap keys.
; Uses "validationEnabled" to avoid collision with wind's "enabled" key.
function loadValidationSection(string sConfig)
	string sectionTag = "<validation>"
	int sectionStart = findStringInString(sectionTag, sConfig, 0)
	if (sectionStart == -1)
		; Section absent — defaults remain from initMap()
		return
	endif
	startIndex = sectionStart
	string val = getTagValue("enabled", sConfig, true, false)
	if (bLastTagFound)
		JMap.setStr(configMapId, "validationEnabled", val)
	endif
	val = getTagValue("warn-triangle-count", sConfig, true, false)
	if (bLastTagFound)
		JMap.setStr(configMapId, "warn-triangle-count", val)
	endif
	val = getTagValue("output-dir", sConfig, true, false)
	if (bLastTagFound)
		JMap.setStr(configMapId, "output-dir", val)
	endif
endfunction

bool function configMatchesPreset(string presetPath)
	string sPreset = MiscUtil.ReadFromFile(presetPath)
	if (sPreset == "")
		return false
	endif
	int savedStartIndex = startIndex
	bool savedLastTagFound = bLastTagFound
	startIndex = 0
	int index = 0
	bool matches = true
	While (index < keys.Length && matches)
		string tag = keys[index]
		string presetValue = getTagValue(tag, sPreset, true, false)
		if (!bLastTagFound)
			matches = false
		else
			string configValue = JMap.getStr(configMapId, tag, "")
			if (configValue != presetValue)
				matches = false
			endif
		endif
		index += 1
	EndWhile
	startIndex = savedStartIndex
	bLastTagFound = savedLastTagFound
	return matches
endfunction

Function toggleTagWithoutStoringConfig(string tag, string toggle)
	string sOldValue = JMap.getStr(configMapId, tag, "")
	bool bNewValue = sOldValue != "true"
	SetToggleOptionValueST(bNewValue, false, toggle)
	string sNewValue = "false"
	if bNewValue
		sNewValue = "true"
	endif
	JMap.setStr(configMapId, tag, sNewValue)
	sLastLoadedPresetName = ""
EndFunction

Function toggleTag(string tag, string toggle)
	toggleTagWithoutStoringConfig(tag, toggle)
	storeConfigAndSmpReset()
EndFunction

function setOpenedSlider(float min, float max, float interval, string tag, float startValue)
	SetSliderDialogRange(min, max)
	SetSliderDialogInterval(interval)
	SetSliderDialogStartValue(JMap.getStr(configMapId, tag, startValue) as float)
	SetSliderDialogDefaultValue(JMap.getStr(configMapId, tag, startValue) as float)
endfunction

function setIntTag(string tag, int value)
	SetSliderOptionValueST(value as float)
	JMap.setStr(configMapId, tag, value)
	sLastLoadedPresetName = ""
	storeConfigAndSmpReset()
endfunction

function setFloatTag(string tag, float value, string formatSTring = "{0}")
	SetSliderOptionValueST(value, formatSTring)
	JMap.setStr(configMapId, tag, value)
	sLastLoadedPresetName = ""
	storeConfigAndSmpReset()
endfunction

string Function buildConfigString()
	string result = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<configs>\n	<smp>\n"
	int index = 0
	string value = ""
	While (index < 14)
		string tag = keys[index]
		value = JMap.getStr(configMapId, tag, "")
		string ev = entaggedValue(tag, value) 
		result += "		" + ev + "\n"
		index += 1
	EndWhile
	result += "	</smp>\n	<solver>\n"
	While (index < 19)
		string tag = keys[index]
		value = JMap.getStr(configMapId, tag, "")
		string ev = entaggedValue(tag, value) 
		result += "		" + ev + "\n"
		index += 1
	EndWhile
	result += "	</solver>\n	<wind>\n"
	While (index < 23)
		string tag = keys[index]
		value = JMap.getStr(configMapId, tag, "")
		string ev = entaggedValue(tag, value) 
		result += "		" + ev + "\n"
		index += 1
	EndWhile
	result += "	</wind>\n	<validation>\n"
	result += "		" + entaggedValue("enabled", JMap.getStr(configMapId, "validationEnabled", "true")) + "\n"
	result += "		" + entaggedValue("warn-triangle-count", JMap.getStr(configMapId, "warn-triangle-count", "10000")) + "\n"
	result += "		" + entaggedValue("output-dir", JMap.getStr(configMapId, "output-dir", "")) + "\n"
	result += "	</validation>\n</configs>"
	return result
endFunction

Function storeConfigAndSmpReset()
	string result = buildConfigString()
	MiscUtil.WriteToFile(configFilePath, result, false)
	ConsoleUtil.ExecuteCommand("smp reset")
EndFunction

string Function entaggedValue(string tag, string value)
	if (value == "true")
		value = ">true<"; lowering case. Yup this is a shameful hack to avoid the shameful handling by papyrus of some specific string like 'TRUE' and 'False'...
	ElseIf (value == "false")
		value = ">false<"; lowering case
	else
		if (tag == "enabled")
			return "<enabled>"+value+"</enabled>"; lowering case
		else
			return "<"+tag+">"+value+"</"+tag+">"
		endif
	endif
	if (tag == "enabled")
		return "<enabled"+value+"/enabled>"; lowering case
	else
		return "<"+tag + value + "/" + tag+">"
	endif
EndFunction

string Function getTagValue(string tag, string sConfig, bool sequential = false, bool warn = false)
	string startTag = "<" + tag + ">"
	string endTag = "</" + tag + ">"
	int tagLength = StringUtil.GetLength(tag)
	int startTagIndex = findStringInString(startTag, sConfig, startIndex)
	if (startTagIndex == -1); not found
		bLastTagFound = false
		return tagDefaultValue(tag, warn)
	endif
	bLastTagFound = true
	int valueIndex = startTagIndex + tagLength + 2
	int endTagIndex = findStringInString(endTag, sConfig, valueIndex)
	if sequential
		startIndex = endTagIndex + tagLength + 3
	endif
	return StringUtil.Substring(sConfig, valueIndex, endTagIndex - valueIndex)
EndFunction

; This function will be called rarely, so a loop is okay
string Function tagDefaultValue(string tag, bool warn = false)
	; TODO use this function in the menu too; will need to use a map rather than a loop
	int i = 0
	while (i < keys.Length)
		if (keys[i] == tag)
			string defaultValue = defaultValues[i]
			if (warn)
				Debug.Notification("FSMP MCM: tag " + tag + " missing from configs.xml, using default " + defaultValue)
			endif
			return defaultValue
		endif
		i = i+1
	endwhile
	return "Will probably CTD"
endfunction

int Function findStringInString(string toFind, string content, int firstIndex = 0)
	int contentIndex = firstIndex
	int toFindLength = StringUtil.GetLength(toFind)
	int contentLength = StringUtil.GetLength(content)

	int currentIndex = 0
	string[] toFindCharacters = PapyrusUtil.StringArray(toFindLength)
	while currentIndex < toFindLength
		toFindCharacters[currentIndex] = StringUtil.GetNthChar(toFind, currentIndex)
		currentIndex = currentIndex + 1
	endwhile
	
	currentIndex = 0
	while contentIndex < contentLength
		string characterFound = StringUtil.GetNthChar(content, contentIndex + currentIndex)		
		if toFindCharacters[currentIndex] == characterFound
			currentIndex += 1
			if currentIndex == toFindLength
				return contentIndex; found at position contentIndex
			endif
		else
			contentIndex += 1
			currentIndex = 0
		endif
	endwhile
	return -1; Not found
EndFunction

; #################################################################################################
; #################################################################################################
; States
; #################################################################################################
; #################################################################################################

State SliderLog
	event OnSliderOpenST()
		setOpenedSlider(0,5,1,"logLevel", 0)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setIntTag("logLevel", a_value as int)
	endEvent

	Event OnHighlightST()
		SetInfoText("0 - Fatal, 1 - Error, 2 - Warning, 3 - Message, 4 - Verbose, 5 - Debug")
	EndEvent
EndState

State SliderRotationSpeedLimit
	event OnSliderOpenST()
		setOpenedSlider(0,100,0.1,"rotationSpeedLimit", 10)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setFloatTag("rotationSpeedLimit", a_value, "{1}")
	endEvent

	Event OnHighlightST()
		SetInfoText("Rotation speed limit in radians / second")
	EndEvent
EndState

State SliderUnclampedResetAngle
	event OnSliderOpenST()
		setOpenedSlider(0,360,1,"unclampedResetAngle", 120)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setFloatTag("unclampedResetAngle", a_value)
	endEvent

	Event OnHighlightST()
		SetInfoText("The angle value in degrees at which the reset occurs")
	EndEvent
EndState

State SliderMinCullingDistance
	event OnSliderOpenST()
		setOpenedSlider(0, 10000, 1, "minCullingDistance", 300)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setFloatTag("minCullingDistance", a_value)
	endEvent

	Event OnHighlightST()
		SetInfoText("The distance from camera below which NPCs SMP is always calculated.\nThis is useful when a NPC is just behind the camera, and his cape should float in front of you.\nWithout this, as the camera doesn't see the NPC, his physics is disabled.")
	EndEvent
EndState

State SliderMaxSkeletons
	event OnSliderOpenST()
		setOpenedSlider(0,200,1,"maximumActiveSkeletons", 40)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setIntTag("maximumActiveSkeletons", a_value as int)
	endEvent

	Event OnHighlightST()
		SetInfoText("The maximum number of NPC, including your character,\nfor which physics is calculated at the same time, when automatically adjusted.")
	EndEvent
EndState

State SliderTimeFrameBudget
	event OnSliderOpenST()
		setOpenedSlider(0.1,16.0,0.1,"budgetMs", 3.5)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setFloatTag("budgetMs", a_value, "{1}")
	endEvent

	Event OnHighlightST()
		SetInfoText("Allowed CPU time for SMP calculus each frame in milliseconds.")
	EndEvent
EndState

State SliderSampleSize
	event OnSliderOpenST()
		setOpenedSlider(1,50,1,"sampleSize", 5)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setIntTag("sampleSize", a_value as int)
	endEvent

	Event OnHighlightST()
		SetInfoText("Adjustment speed -- the higher, the slower")
	EndEvent
EndState

State SliderNumIterations
	event OnSliderOpenST()
		setOpenedSlider(4,128,1,"numIterations", 16)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setIntTag("numIterations", a_value as int)
	endEvent

	Event OnHighlightST()
		SetInfoText("Simulation quality")
	EndEvent
EndState

State SliderERP
	event OnSliderOpenST()
		setOpenedSlider(0.01, 0.99, 0.01, "erp", 0.2)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setFloatTag("erp", a_value, "{2}")
	endEvent

	Event OnHighlightST()
		SetInfoText("The error correction force applied to move the constraints-enabled bones back to where they're supposed to be.")
	EndEvent
EndState

State SliderMinFPS
	event OnSliderOpenST()
		setOpenedSlider(60,300,1,"min-fps", 60)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setIntTag("min-fps", a_value as int)
	endEvent

	Event OnHighlightST()
		SetInfoText("Simulation frequency, in simulations per second")
	EndEvent
EndState

State SliderMaxSubsteps
	event OnSliderOpenST()
		setOpenedSlider(1,60,1,"maxSubSteps", 2)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setIntTag("maxSubSteps", a_value as int)
	endEvent

	Event OnHighlightST()
		SetInfoText("The max number of simulations per frame\nThis allows to avoid calculating physics too much when fps is low.\nThere will be slowdowns when the fps is under (simulation frequency / this value).")
	EndEvent
EndState

State SliderWindStrength
	event OnSliderOpenST()
		setOpenedSlider(0, 100, 0.1, "windStrength", 2.0); FSMP allows for strength 1000...
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setFloatTag("windStrength", a_value, "{1}")
	endEvent

	Event OnHighlightST()
		SetInfoText("Wind strength. 9.8 would be equivalent to gravity.")
	EndEvent
EndState

State SliderNoWindDistance
	event OnSliderOpenST()
		setOpenedSlider(0, 10000, 1, "distanceForNoWind", 50.0)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setFloatTag("distanceForNoWind", a_value)
	endEvent

	Event OnHighlightST()
		SetInfoText("How close to an obstruction for wind to be fully blocked.\nWind strength scales linearly between the distance for no wind and the distance for max wind.")
	EndEvent
EndState

State SliderMaxWindDistance
	event OnSliderOpenST()
		setOpenedSlider(0, 10000, 1, "distanceForMaxWind", 2500.0)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setFloatTag("distanceForMaxWind", a_value)
	endEvent

	Event OnHighlightST()
		SetInfoText("How far from an obstruction for wind to be not blocked.\nWind strength scales linearly between the distance for no wind and the distance for max wind. ")
	EndEvent
EndState

State ToggleValidationEnabled
	Event OnSelectST()
		toggleTag("validationEnabled", "ToggleValidationEnabled")
		ForcePageReset()
	EndEvent

	Event OnHighlightST()
		SetInfoText("Check to run the FSMP asset validator when the game loads.\nResults are written to the SKSE log directory.")
	EndEvent
EndState

State SliderWarnTriangleCount
	event OnSliderOpenST()
		setOpenedSlider(0, 100000, 1000, "warn-triangle-count", 10000)
	endEvent

	event OnSliderAcceptST(float a_value)
		setIntTag("warn-triangle-count", a_value as int)
	endEvent

	Event OnHighlightST()
		SetInfoText("Warn when a physics-enabled NIF contains more triangles than this threshold.\nHigh triangle counts can impact simulation performance.")
	EndEvent
EndState

State InputOutputDir
	Event OnInputOpenST()
		SetInputDialogStartText(JMap.getStr(configMapId, "output-dir", ""))
	EndEvent

	Event OnInputAcceptST(string a_input)
		JMap.setStr(configMapId, "output-dir", a_input)
		storeConfigAndSmpReset()
		SetInputOptionValueST(a_input)
	EndEvent

	Event OnHighlightST()
		SetInfoText("Folder where improved physics XML files will be written.\nLeave blank to disable improved file generation.")
	EndEvent
EndState

State ToggleNPCFaceParts
	Event OnSelectST()
		toggleTag("enableNPCFaceParts", "ToggleNPCFaceParts")
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Uncheck to disable managing NPC face parts")
	EndEvent
EndState

State ToggleSMPHairWhenWigEquipped
	Event OnSelectST()
		toggleTag("disableSMPHairWhenWigEquipped", "ToggleSMPHairWhenWigEquipped")
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Check to avoid calculating SMP hair where there is a wig on top of the hair")
	EndEvent
EndState

State ToggleClampRotations
	Event OnSelectST()
		toggleTag("clampRotations", "ToggleClampRotations")
		ForcePageReset()
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Check to limit the your character rotation speed when turning a large angle, so that it rotates slowly instead of instantly.")
	EndEvent
EndState

State ToggleClampedResets
	Event OnSelectST()
		toggleTag("unclampedResets", "ToggleClampedResets")
		ForcePageReset()
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("When the rotation speed is NOT limited, and this is unchecked,\nif you do a large turn (full 180 degrees for example), physics will be calculated.\nCheck to instead trigger a physics reset when the turn is large enough.")
	EndEvent
EndState

State ToggleRealTime
	Event OnSelectST()
		toggleTag("useRealTime", "ToggleRealTime")
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Check to use your real time rather than the inner game time (better when using slow time)")
	EndEvent
EndState

State ToggleAutoAdjustMaxSkeletons
	Event OnSelectST()
		toggleTag("autoAdjustMaxSkeletons", "ToggleAutoAdjustMaxSkeletons")
		ForcePageReset()
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Check to auto adjust the max number of SMP NPCs, else it's 10")
	EndEvent
EndState

State Toggle1stPersonViewPhysics
	Event OnSelectST()
		toggleTag("disable1stPersonViewPhysics", "Toggle1stPersonViewPhysics")
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Check to avoid calculating your character physics when in 1st person view")
	EndEvent
EndState

State ToggleWind
	Event OnSelectST()
		toggleTag("enabled", "ToggleWind")
		ForcePageReset()
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Check to enable FSMP-native wind")
	EndEvent
EndState

State ToggleSMP
	Event OnSelectST()
		bSMPOn = !bSMPOn
		SetToggleOptionValueST(bSMPOn, false, "ToggleSMP")
		if bSMPOn
			ConsoleUtil.ExecuteCommand("smp on")
		else
			ConsoleUtil.ExecuteCommand("smp off")
		endif
		Debug.Messagebox(ConsoleUtil.ReadMessage())
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Uncheck to disable SMP (Skinned Mesh Physics)")
	EndEvent
EndState

State SMP
	Event OnSelectST()
		ConsoleUtil.ExecuteCommand("smp")
		Debug.Messagebox("Done: check the info in the console")
    EndEvent
    
	Event OnHighlightST()
		SetInfoText("Click to have basic information")
	EndEvent
EndState

State SMPReset
	Event OnSelectST()
		ConsoleUtil.ExecuteCommand("smp reset")
		Debug.Messagebox("Done: smp reset")
    EndEvent
    
	Event OnHighlightST()
		SetInfoText("Resets the physics calculation")
	EndEvent
EndState

State SMPDumptree
	Event OnSelectST()
		ConsoleUtil.ExecuteCommand("smp dumptree")
		Debug.Messagebox("Done: smp dumptree. Check your hdtSMP64.log")
    EndEvent
    
	Event OnHighlightST()
		SetInfoText("Dumps the whole data tree of a NPC in the logs. You need a log level of 3 or more.\nYou need to open the console and target a NPC, then either click here or do 'smp dumptree' in the console.\nThe NPC tree will be dumped in your log file,\ngenerally C:/Users/your_user_name/Documents/My Games/Skyrim Special Edition/SKSE/hdtSMP64.log.")
	EndEvent
EndState

State SMPDetail
	Event OnSelectST()
		ConsoleUtil.ExecuteCommand("smp detail")
		Debug.Messagebox("Done: check the detail in the console")
    EndEvent
    
	Event OnHighlightST()
		SetInfoText("Click to have detailed information")
	EndEvent
EndState

State SMPList
	Event OnSelectST()
		ConsoleUtil.ExecuteCommand("smp list")
		Debug.Messagebox("Done: check the list in the console")
    EndEvent
    
	Event OnHighlightST()
		SetInfoText("Click to have a list of informations")
	EndEvent
EndState

State SMPQueryOverridde
	Event OnSelectST()
		ConsoleUtil.ExecuteCommand("smp QueryOverridde")
		Debug.Messagebox("Done: smp QueryOverridde")
    EndEvent
    
	Event OnHighlightST()
		SetInfoText("Click to QueryOverridde")
	EndEvent
EndState

State SMPValidate
	Event OnSelectST()
		ConsoleUtil.ExecuteCommand("smp validate")
		Debug.Messagebox("Validation started in the background.\nOpen the console to see results and the report path when it completes.")
    EndEvent

	Event OnHighlightST()
		SetInfoText("Click to run the FSMP asset validator now.\nValidation runs in the background. When complete, the console shows the results and the path of the timestamped report file written to your SKSE log directory.")
	EndEvent
EndState

State SMPValidateGear
	Event OnSelectST()
		ConsoleUtil.ExecuteCommand("smp validate gear")
		Debug.Messagebox("Equipped gear validation started in the background.\nOpen the console to see results and the report path when it completes.")
    EndEvent

	Event OnHighlightST()
		SetInfoText("Click to run the FSMP asset validator on currently equipped gear only.\nValidation runs in the background. When complete, the console shows the results and the path of the timestamped report file written to your SKSE log directory.")
	EndEvent
EndState
