// ActionScript file

import mx.controls.Alert;
import NetConnectionClient;
import flash.events.NetStatusEvent;
import mx.events.ListEvent;
import mx.events.VideoEvent;
 		
public var nc:NetConnection;
public var nsPublish:NetStream;   

// Parameters assigned from flash vars
public var rtmp_url:String;
public var token:String;

private var isLive:Boolean = false;
private var camera:Camera;
private var mic:Microphone;
private var preCamera:Camera;

// Register callback to expose function to javascript
//ExternalInterface.addCallback("initCamera", initCameras);
//ExternalInterface.addCallback("startPublishing", startPublishing);
		
// Assign values to new properties.
private function initVars():void {
  Security.showSettings(SecurityPanel.PRIVACY);
  rtmp_url = mx.core.FlexGlobals.topLevelApplication.parameters.rtmp_url;
  token = mx.core.FlexGlobals.topLevelApplication.parameters.id;
  // Register callback to expose function to javascript
  ExternalInterface.addCallback("startPublishing", startPublishing);
  ExternalInterface.addCallback("stopPublishing", stopPublishing);
  initCameras();
}

private function drawMicLevel(evt:TimerEvent):void {
  var ac:int=mic.activityLevel;
  micLevel.setProgress(ac,100);
}

// Show all cameras
private function initCameras():void {

  // Attach first camera to video show
  camera = Camera.getCamera("0");
  pubVideo.attachCamera(camera);

  // Show prev and cameras only if there is more than one
  var cams:Array = Camera.names;
  if (cams.length > 1) {
    cameras.includeInLayout=true;
    previous.includeInLayout=true;
    preCamera = Camera.getCamera("0");
    preVideo.visible = true;
    preVideoLabel.visible = true;
    preVideo.attachCamera(preCamera);
  }

  // We dont need to see all cameras until picture and VTR were available
  //for (var i:int = 0; i < 6; i++) {
  //  var _cam:DisplayObject = cameras.getChildByName('cam'+i.toString());
  //  var _camLabel:DisplayObject = cameras.getChildByName('cam'+i.toString()+'Label');
  //  _cam.visible = true;
  //  _camLabel.visible = true; 
  //}

  // Initialize parameters of webcams
  for (var camId:String in cams) {
    var cam:Camera = Camera.getCamera(camId);
    cam.setMode(320, 240, 30, false);
    cam.setQuality(0, 88);
    cam.setKeyFrameInterval(15);
    if (cams.length > 1) {
      var _camVideo:VideoDisplay = cameras.getChildByName('cam'+camId) as VideoDisplay;
      var _camLabel:DisplayObject = cameras.getChildByName('cam'+camId+'Label');
      _camVideo.attachCamera(cam);
      _camVideo.visible = true;
      _camLabel.visible = true;
    }
  }

  // Initialize microphone
  mic = Microphone.getMicrophone(0);
  if (mic!=null) {
    mic.rate = 22;
    mic.gain = 100;
    mic.setUseEchoSuppression(true);
    mic.setLoopBack(true);
    mic.setSilenceLevel(5, 1000);
    var timer:Timer=new Timer(50);
    timer.addEventListener(TimerEvent.TIMER, drawMicLevel);
    timer.start();
  }
}

private function changePrev(camId:int):void {
  preCamera = Camera.getCamera(camId.toString());
  preVideo.attachCamera(preCamera);
}

private function changePub():void {
  var _cam:Camera = camera;
  camera = preCamera;
  preCamera = _cam;
  pubVideo.attachCamera(camera);
  preVideo.attachCamera(preCamera);
  if (nc.connected) {
    nsPublish.attachCamera(camera);
  }	
}

private function changeCamera(evt:ListEvent):void {
  var cameraName:String = evt.currentTarget.selectedIndex.toString();
  camera = Camera.getCamera(cameraName);
  pubVideo.attachCamera(camera);
  if (nc.connected) {
    nsPublish.attachCamera(camera);
  }
}

// Initializing Connection and invoking publishStream
private function startPublishing():void{
  if (camera == null) {
    initCameras();
  }
  isLive = true;
  fadeIn.play([rec]);
  nc = new NetConnection();
  nc.client = new NetConnectionClient();	
  nc.objectEncoding = flash.net.ObjectEncoding.AMF0;	      			
  nc.connect("rtmp://" + rtmp_url + "?id=" + token); //Path to FMS Server e.g. rtmp://<hostname>/<application name>

  nc.addEventListener("netStatus", publishStream);	//Listener to see if connection is successful
}

// Stop publishing now
private function stopPublishing():void{
  isLive = false;
  nc.close();
  fadeOut.play([rec]);
  //pubVideo.attachCamera(null);
  //pubVideo.mx_internal::videoPlayer.clear();
}

private function publishStream(event:NetStatusEvent):void{
  if(nc.connected){
    nsPublish = new NetStream(nc);  //Initializing NetStream
    nsPublish.attachCamera(camera);
    nsPublish.attachAudio(mic); //Attaching Camera & Microphone
    nsPublish.publish("live"); //Publish stream
  } else {
    // Only show error if camera is active
    if (isLive) {
        isLive = false;
        mx.controls.Alert.show("Connection Error");
    }
  }
}

private function showControls():void {
  fadeIn.play([controls]);
}
 
private function hideControls():void {
  fadeOut.play([controls]);
}
