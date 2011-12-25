package {

  public class NetConnectionClient {

    public function NetConnectionClient() {
    }

    public function onBWDone(... rest):void {
    }
   
    public function onBWCheck(... rest):uint {
      return 0;
    }
    
    public function onMetaData(info:Object):void {
      trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
    }
  }
}
