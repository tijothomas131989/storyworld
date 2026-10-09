import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const StoryWorldApp());
}

class StoryWorldApp extends StatelessWidget {
  const StoryWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoryWorld',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB07A3B),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_storyWorldHtml());
  }

  String _storyWorldHtml() {
    return '''
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
        <style>
          html, body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            background: #0c1016;
            font-family: sans-serif;
          }
          canvas {
            width: 100%;
            height: 100%;
            display: block;
          }
          #hud {
            position: absolute;
            top: 20px;
            left: 20px;
            z-index: 10;
            color: #f4d7a3;
            font-size: 14px;
            font-weight: bold;
            background: rgba(0,0,0,0.25);
            padding: 10px 12px;
            border-radius: 10px;
            backdrop-filter: blur(4px);
          }
        </style>
      </head>
      <body>
        <div id="hud">STORYWORLD • Babylon Test Scene</div>
        <canvas id="renderCanvas"></canvas>

        <script src="https://cdn.babylonjs.com/babylon.js"></script>
        <script>
          const canvas = document.getElementById("renderCanvas");
          const engine = new BABYLON.Engine(canvas, true);

          const createScene = function () {
            const scene = new BABYLON.Scene(engine);
            scene.clearColor = new BABYLON.Color4(0.07, 0.08, 0.12, 1);

            const camera = new BABYLON.ArcRotateCamera(
              "camera",
              -Math.PI / 2,
              Math.PI / 3,
              18,
              new BABYLON.Vector3(0, 2, 0),
              scene
            );
            camera.attachControl(canvas, true);
            camera.lowerRadiusLimit = 8;
            camera.upperRadiusLimit = 40;
            camera.wheelPrecision = 25;

            const light = new BABYLON.HemisphericLight(
              "light",
              new BABYLON.Vector3(0, 1, 0),
              scene
            );
            light.intensity = 1.2;
            light.groundColor = new BABYLON.Color3(0.4, 0.35, 0.3);

            const sun = new BABYLON.DirectionalLight(
              "sun",
              new BABYLON.Vector3(-1, -2, -1),
              scene
            );
            sun.intensity = 1.4;

            const ground = BABYLON.MeshBuilder.CreateGround("ground", {
              width: 60,
              height: 60,
              subdivisions: 20
            }, scene);
            ground.position.y = 0;

            const groundMat = new BABYLON.StandardMaterial("groundMat", scene);
            groundMat.diffuseColor = new BABYLON.Color3(0.35, 0.26, 0.18);
            groundMat.specularColor = new BABYLON.Color3(0.1, 0.1, 0.1);
            ground.material = groundMat;

            const towerMaterial = new BABYLON.StandardMaterial("towerMat", scene);
            towerMaterial.diffuseColor = new BABYLON.Color3(0.72, 0.66, 0.48);
            towerMaterial.specularColor = new BABYLON.Color3(0.5, 0.5, 0.45);

            const stoneMaterial = new BABYLON.StandardMaterial("stoneMat", scene);
            stoneMaterial.diffuseColor = new BABYLON.Color3(0.58, 0.54, 0.47);

            const tower = BABYLON.MeshBuilder.CreateCylinder("tower", {
              diameter: 3.2,
              height: 12,
              tessellation: 32
            }, scene);
            tower.position.y = 6;
            tower.material = towerMaterial;

            const towerTop = BABYLON.MeshBuilder.CreateCylinder("towerTop", {
              diameter: 1.8,
              height: 2.3,
              tessellation: 20
            }, scene);
            towerTop.position.y = 13.2;
            towerTop.material = towerMaterial;

            const cityBlocks = [];
            for (let i = 0; i < 18; i++) {
              const x = (Math.random() - 0.5) * 20;
              const z = (Math.random() - 0.5) * 20;
              const height = 1.2 + Math.random() * 3.2;

              const block = BABYLON.MeshBuilder.CreateBox("box" + i, {
                width: 1.4 + Math.random() * 1.1,
                height: height,
                depth: 1.4 + Math.random() * 1.1
              }, scene);

              block.position = new BABYLON.Vector3(x, height / 2, z);
              block.material = stoneMaterial;
              cityBlocks.push(block);
            }

            const road = BABYLON.MeshBuilder.CreateGround("road", {
              width: 8,
              height: 28,
            }, scene);
            road.position.y = 0.02;
            road.rotation.y = Math.PI / 2;

            const roadMat = new BABYLON.StandardMaterial("roadMat", scene);
            roadMat.diffuseColor = new BABYLON.Color3(0.28, 0.27, 0.25);
            road.material = roadMat;

            const dustParticles = new BABYLON.ParticleSystem("dust", 300, scene);
            dustParticles.particleTexture = new BABYLON.Texture(
              "https://assets.babylonjs.com/textures/flare.png",
              scene
            );
            dustParticles.emitter = new BABYLON.Vector3(0, 2, 0);
            dustParticles.minLifeTime = 1;
            dustParticles.maxLifeTime = 3;
            dustParticles.minSize = 0.05;
            dustParticles.maxSize = 0.2;
            dustParticles.minEmitPower = 0.01;
            dustParticles.maxEmitPower = 0.02;
            dustParticles.emitRate = 50;
            dustParticles.direction1 = new BABYLON.Vector3(-1, 0.5, -1);
            dustParticles.direction2 = new BABYLON.Vector3(1, 0.8, 1);
            dustParticles.minAngularSpeed = 0;
            dustParticles.maxAngularSpeed = 0.2;
            dustParticles.start();

            let angle = 0;

            scene.registerBeforeRender(() => {
              angle += 0.005;
              camera.alpha += 0.003;
              camera.target.y = 1.8 + Math.sin(angle * 2) * 0.4;
            });

            return scene;
          };

          const scene = createScene();

          engine.runRenderLoop(function () {
            scene.render();
          });

          window.addEventListener("resize", function () {
            engine.resize();
          });
        </script>
      </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StoryWorld'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
