![Hero image showing the configuration abilities of IMGLYEngine](https://img.ly/static/cesdk_release_header_ios.png)

# IMGLY Creative Engine - Swift Examples

This repository contains the Swift examples for the IMG.LY *Creative Engine*, the core of CE.SDK. 
The Creative Engine enables you to build any design editing UI, automation and creative workflow in Swift.
It offers performant and robust graphics processing capabilities combining the best of layout, typography and image processing with advanced workflows centered around templating and adaptation. 

The Creative Engine seamlessly integrates into any iOS app whether you are building a photo editor, template-based design tool or scalable automation of content creation for your app.

Visit our [documentation](https://img.ly/docs/cesdk) for more tutorials on how to integrate and
customize the engine for your specific use case.

## Documentation
The full documentation of IMGLYEngine can be found at
[here](https://img.ly/docs/cesdk/ios/).
There you will learn what configuration options are available and find a list
and description of all API methods.

## License

The IMGLYEngine is a commercial product. To use it you need to unlock the SDK with a license file. You can purchase a license at https://img.ly/pricing.

In order to run the `CESDK-Showcases` application in this repository use the instructions below:
1. Get a free trial license at https://img.ly/forms/free-trial. Note that the license is tied to the bundle identifier of the application. Since the bundle identifier of the `CESK-Showcases` app is `ly.img.ubq.CESDK-Showcases`, you should include it in the list of bundle ids.
   ![alt text](./bundle_id_instruction.png)
2. Copy the license string.
3. Include the license string in the `secrets/Secrets.swift` file:
```
licenseKey: ...
```

Note that failing to provide the license key will display an error when opening any of the showcases.
