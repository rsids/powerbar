using Toybox.Application;

class powerbarApp extends Application.AppBase {

	var zones = [.55, .75, .9, 1.05, 1.2, 1.5];

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new powerbarView() ];
    }

}