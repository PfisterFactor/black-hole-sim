import * as THREE from 'three';
import background_vertex from "./resources/shaders/background/vertex.glsl";
import background_frag from "./resources/shaders/background/frag.glsl";

import blackhole_vertex from "./resources/shaders/black_hole/vertex.glsl";
import blackhole_frag from "./resources/shaders/black_hole/frag.glsl";
import { visibleHeightAtZDepth, visibleWidthAtZDepth } from './resources/util';
import { CircleGeometry, ShaderMaterial, Uniform, Vector3 } from 'three';

let camera: THREE.Camera;
let scene: THREE.Scene;
let renderer: THREE.WebGLRenderer;

let background: THREE.Mesh;
let blackhole: THREE.Mesh;

let time: number = 0;
// As percent of screen
const BLACKHOLE_RADIUS = 0.1;

function CreateBackground() {
    // Make the background plane right next to the far clipping plane
    const z = 0;
    const background_material = new THREE.ShaderMaterial({
        uniforms: {
            time: new Uniform(time),
            resolution: new Uniform([visibleWidthAtZDepth(z, camera), visibleHeightAtZDepth(z, camera)])
        },
        vertexShader: background_vertex,
        fragmentShader: background_frag
    })
    // Create a background plane at the far clipping plane
    background = new THREE.Mesh(new THREE.PlaneBufferGeometry(visibleWidthAtZDepth(z, camera), visibleHeightAtZDepth(z, camera), 1, 1), background_material);
    background.position.setZ(z);

    scene.add(background);
}
function CreateBlackhole() {
    const z = 0;
    const blackhole_material = new THREE.ShaderMaterial({
        uniforms: {
            time: new Uniform(time),
            resolution: new Uniform([visibleWidthAtZDepth(z, camera), visibleHeightAtZDepth(z, camera)])
        },
        vertexShader: blackhole_vertex,
        fragmentShader: blackhole_frag
    });
    
    blackhole = new THREE.Mesh(new CircleGeometry(visibleWidthAtZDepth(z, camera) * BLACKHOLE_RADIUS,36),blackhole_material);
    scene.add(blackhole);
    
}

function init() {
    scene = new THREE.Scene();
    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    renderer = new THREE.WebGLRenderer({
        antialias: true,
    });
    renderer.setSize(window.innerWidth, window.innerHeight);
    window.addEventListener('resize', function (e) {
        renderer.setSize(window.innerWidth, window.innerHeight);
        (<ShaderMaterial>background.material).uniforms.resolution = new Uniform([visibleWidthAtZDepth(0, camera), visibleHeightAtZDepth(0, camera)]);
    });
    document.body.appendChild(renderer.domElement);
    camera.position.z = 1;

    CreateBackground();
    // CreateBlackhole();
}
function UpdateUniforms() {
    (<ShaderMaterial>background.material).uniforms.time = new Uniform(time);
}
function animate() {
    requestAnimationFrame(animate);
    UpdateUniforms();
    renderer.render(scene, camera);
    time += 1;
}

init();
animate();