# Import file "location" (sizes and positions are scaled 1:3)
locations = Framer.Importer.load("imported/location@3x")

#making all layers from sketch available to address using just their name
Utils.globalLayers locations

#creating boolean variables for different conditions
dragged=false
full=false
half=false

#creating slideholder
slider=new Layer
	width:Screen.width, height:723, x:0, y:1740

#pageComponent will be used for our slideshow
slideShow=new PageComponent
	width:Screen.width, height:723, x:0, y:0, scrollVertical: false, superLayer: slider
slideShow.animationOptions = curve: "spring(200,22,0)"

#array holding path to our slideshow images
images=["images/image1.jpg","images/image2.jpg","images/image3.jpg",]


#page indicator code used from this example made by Benjamin de Boer
#http://framerjs.com/examples/preview/#page-indicators.framer#code
allIndicators = []	
amount = 3

for i in [0...amount]
	slide=new Layer
		#creating slides for slideshow and attaching proper image to each slide
		width:slider.width, height:723, image:images[i]
	#ading slides to slideshow (pageComponent)
	slideShow.addPage(slide, "right")
	#creating indicators
	indicator = new Layer 
		backgroundColor: "#fff"
		width: 16, height: 16
		x: 32 * i, y: 650
		borderRadius: "50%", opacity: 0.8
		superLayer: slider
		
	# Stay centered regardless of the amount of cards
	indicator.x += (Screen.width / 2) - (12 * amount)
	
	# States
	indicator.states.add(active: {opacity: 1, scale:1.5})
	indicator.states.animationOptions = time: 0.5
	# Store indicators in our array
	allIndicators.push(indicator)
#making first indicator in active state
allIndicators[0].states.switch("active")
# Update indicators	
slideShow.on "change:currentPage", ->
	indicator.states.switch("default") for indicator in allIndicators
	current = slideShow.horizontalPageIndex(slideShow.currentPage)
	allIndicators[current].states.switch("active")
#creation of holder for main interactive layers
globalLayer=new Layer
	x:0, y:-80, width:Screen.width, height: Screen.height, backgroundColor: "null"

#taking  interactive layers from sketch(locations) objects and attaching them to globalLayer as sublayer, for better interactions
for i in [slider,footer, header, review]	
	globalLayer.addChild(i)

#adding different states for layers by defyining position and opacity for them on step when half of info for location is visible plus slideshow, and for full state - when full info is visible without slideshow
footer.states.add
	half:
		y: 690
	full:
		y:-200
		
footer.states.animationOptions =
	time: 0.2, curve: "ease"

meta.states.add
	full:
		opacity:0
		
meta.states.animationOptions =
	time: 0.2, curve: "ease"

directionWhite.states.add
	full:
		opacity:0
		scale:0.1
		
directionWhite.states.animationOptions =
	time: 0.2, curve: "ease"

title.opacity=0     
title.states.add
	full:
		opacity:1
		
title.states.animationOptions =
     time: 0.2, curve: "ease"

slider.states.add
	half:
		y: 70
slider.states.animationOptions =
	time: 0.3, curve: "ease"
    
searchBar.states.add
	half:
		y: -100
searchBar.states.animationOptions =
    time: 0.3, curve: "ease"
		
header.y=0
header.opacity=0
header.states.add
	half:
		opacity:1
		y: 132

defaultBrief.states.add
	half:
		opacity: 0
defaultBrief.states.animationOptions =
    time: 0.3, curve: "ease"

#specifying functions for changing states for number of layers - default, half and full
defaultState=->
	for i in [footer,slider, header,searchBar, defaultBrief, directionWhite, title, meta]
		i.states.switch("default")
	#we will use booleans for conditional logic for dragging interactions
	half=false
	full=false
halfState=->
	for i in [ directionWhite, title, meta]
		i.states.switch("default")
	for i in [footer,slider, header,searchBar, defaultBrief]
		i.states.switch("half")
	half=true
	full=false
fullState=->
	for i in [footer, directionWhite, title, meta]
		i.states.switch("full")
	half=false
	full=true

#making our infofooter draggable, specifying constraints for dragging
footer.draggable.enabled=true
footer.draggable.horizontal = false
footer.draggable.overdrag = false
footer.draggable.momentum = false
footer.draggable.directionLock = true
footer.draggable.constraints=
	x:0, y:-180, width:Screen.width, height:Screen.height+info.height+280


# 	hack to differentiate click event and drag end event, cause behaviour is different
footer.on Events.DragStart,->
	dragged=true

#using utils modulate we are chaning Y position and opacity of some objects depending on Y position of the footer
footer.onDrag ->
	if footer.y<1538
		defaultBrief.states.switchInstant("half")
	if footer.y>600
		slider.y=Utils.modulate(footer.y,[690,1850],[70,2168],true)
		searchBar.y=Utils.modulate(footer.y,[690,1850],[-100,90],true)
		header.y=Utils.modulate(footer.y,[690,1250],[132,0],true)
		header.opacity=Utils.modulate(footer.y,[690,1250],[1,0],true)
	else if footer.y<600
		meta.opacity=Utils.modulate(footer.y,[0,200],[0,1],true)
		title.opacity=Utils.modulate(footer.y,[0,100],[1,0],true)
	if footer.y<300
		directionWhite.states.switch("full")
	if footer.y>320
		directionWhite.states.switch("default")

#if we drags end and we haven't dragged to the finished state (default, half or full), we are helping objects to jump to nearest state
footer.onDragEnd ->
	if dragged
		if half and footer.y>780 or !half and footer.y>1500
			defaultState()
		else if !half and footer.y<1500 or half and footer.y<780 and footer.y>400
			halfState()
		else if half and footer.y<400
			fullState()
		dragged=false
		
#clicking on brief description of location let us jump between full and half state for the layers
brief.onClick ->
	if !dragged
		if half
			defaultState()
		else if not full
			halfState()
			
#clicking back button brings us back to default view with map
back.onClick ->
	defaultState()
	
