class ThreeJSAvatarMaker {
    constructor() {
        this.scene = null;
        this.camera = null;
        this.renderer = null;
        this.controls = null;
        this.avatarGroup = null;
        this.autoRotate = false;
        
        this.avatarConfig = {
            face: 'round',
            skinColor: '#fdbcb4',
            eyes: 'normal',
            eyeColor: '#4a4a4a',
            nose: 'normal',
            mouth: 'smile',
            hair: 'short',
            hairColor: '#8b4513',
            accessories: 'none',
            bodyType: 'average',
            top: 't-shirt',
            topColor: '#3498db',
            bottom: 'jeans',
            bottomColor: '#2c3e50',
            shoes: 'sneakers',
            shoeColor: '#34495e',
            pose: 'standing'
        };
        
        this.init();
    }
    
    init() {
        this.setupThreeJS();
        this.setupEventListeners();
        this.setupDefaultSelections();
        this.createAvatar();
        this.animate();
    }
    
    setupThreeJS() {
        const container = document.getElementById('threejs-container');
        
        // Scene
        this.scene = new THREE.Scene();
        this.scene.background = new THREE.Color(0xf8f9fa);
        
        // Camera
        this.camera = new THREE.PerspectiveCamera(
            75, 
            container.clientWidth / container.clientHeight, 
            0.1, 
            1000
        );
        this.camera.position.set(0, 0, 5);
        
        // Renderer
        this.renderer = new THREE.WebGLRenderer({ antialias: true });
        this.renderer.setSize(container.clientWidth, container.clientHeight);
        this.renderer.shadowMap.enabled = true;
        this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
        container.appendChild(this.renderer.domElement);
        
        // Controls
        this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
        this.controls.enableDamping = true;
        this.controls.dampingFactor = 0.05;
        this.controls.enableZoom = true;
        this.controls.enablePan = false;
        this.controls.minDistance = 3;
        this.controls.maxDistance = 10;
        
        // Lighting
        this.setupLighting();
        
        // Avatar group
        this.avatarGroup = new THREE.Group();
        this.scene.add(this.avatarGroup);
        
        // Handle window resize
        window.addEventListener('resize', () => this.onWindowResize());
    }
    
    setupLighting() {
        // Ambient light
        const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
        this.scene.add(ambientLight);
        
        // Main directional light
        const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
        directionalLight.position.set(5, 5, 5);
        directionalLight.castShadow = true;
        directionalLight.shadow.mapSize.width = 2048;
        directionalLight.shadow.mapSize.height = 2048;
        directionalLight.shadow.camera.near = 0.5;
        directionalLight.shadow.camera.far = 50;
        directionalLight.shadow.camera.left = -10;
        directionalLight.shadow.camera.right = 10;
        directionalLight.shadow.camera.top = 10;
        directionalLight.shadow.camera.bottom = -10;
        this.scene.add(directionalLight);
        
        // Fill light
        const fillLight = new THREE.DirectionalLight(0xffffff, 0.3);
        fillLight.position.set(-5, 0, 5);
        this.scene.add(fillLight);
        
        // Rim light
        const rimLight = new THREE.DirectionalLight(0xffffff, 0.4);
        rimLight.position.set(0, 0, -5);
        this.scene.add(rimLight);
    }
    
    setupEventListeners() {
        // Option buttons
        document.querySelectorAll('.option-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const feature = e.target.dataset.feature;
                const value = e.target.dataset.value;
                
                // Update active state
                document.querySelectorAll(`[data-feature="${feature}"]`).forEach(b => b.classList.remove('active'));
                e.target.classList.add('active');
                
                // Update config
                this.avatarConfig[feature] = value;
                this.createAvatar();
            });
        });
        
        // Color pickers
        document.getElementById('skinColor').addEventListener('change', (e) => {
            this.avatarConfig.skinColor = e.target.value;
            this.createAvatar();
        });
        
        document.getElementById('eyeColor').addEventListener('change', (e) => {
            this.avatarConfig.eyeColor = e.target.value;
            this.createAvatar();
        });
        
        document.getElementById('hairColor').addEventListener('change', (e) => {
            this.avatarConfig.hairColor = e.target.value;
            this.createAvatar();
        });
        
        document.getElementById('topColor').addEventListener('change', (e) => {
            this.avatarConfig.topColor = e.target.value;
            this.createAvatar();
        });
        
        document.getElementById('bottomColor').addEventListener('change', (e) => {
            this.avatarConfig.bottomColor = e.target.value;
            this.createAvatar();
        });
        
        document.getElementById('shoeColor').addEventListener('change', (e) => {
            this.avatarConfig.shoeColor = e.target.value;
            this.createAvatar();
        });
        
        // Control buttons
        document.getElementById('downloadBtn').addEventListener('click', () => {
            this.downloadAvatar();
        });
        
        document.getElementById('resetCameraBtn').addEventListener('click', () => {
            this.resetCamera();
        });
        
        document.getElementById('rotateBtn').addEventListener('click', () => {
            this.toggleAutoRotate();
        });
    }
    
    setupDefaultSelections() {
        // Set default active buttons
        Object.keys(this.avatarConfig).forEach(feature => {
            const value = this.avatarConfig[feature];
            const btn = document.querySelector(`[data-feature="${feature}"][data-value="${value}"]`);
            if (btn) {
                btn.classList.add('active');
            }
        });
    }
    
    createAvatar() {
        // Clear existing avatar
        this.avatarGroup.clear();
        
        // Create avatar parts
        this.createHead();
        this.createBody();
        this.createArms();
        this.createLegs();
        this.createClothing();
        this.createAccessories();
    }
    
    createHead() {
        const headGroup = new THREE.Group();
        
        // More human-like head proportions with better shape alignment
        let headGeometry;
        switch (this.avatarConfig.face) {
            case 'round':
                headGeometry = new THREE.SphereGeometry(0.65, 32, 32);
                break;
            case 'oval':
                headGeometry = new THREE.SphereGeometry(0.65, 32, 32);
                headGeometry.scale(0.85, 1.15, 0.75);
                break;
            case 'square':
                // Create a more realistic square face using sphere with scaling
                headGeometry = new THREE.SphereGeometry(0.65, 24, 24);
                headGeometry.scale(1.05, 1.0, 0.85);
                break;
            case 'heart':
                headGeometry = new THREE.SphereGeometry(0.65, 32, 32);
                headGeometry.scale(0.95, 1.05, 0.85);
                break;
            case 'diamond':
                headGeometry = new THREE.SphereGeometry(0.65, 32, 32);
                headGeometry.scale(0.8, 1.25, 0.8);
                break;
            default:
                headGeometry = new THREE.SphereGeometry(0.65, 32, 32);
        }
        
        // More realistic skin material
        const headMaterial = new THREE.MeshLambertMaterial({ 
            color: this.avatarConfig.skinColor,
            transparent: false
        });
        
        const head = new THREE.Mesh(headGeometry, headMaterial);
        head.castShadow = true;
        head.receiveShadow = true;
        headGroup.add(head);
        
         // Create facial features with better alignment
         this.createEyes(headGroup);
         this.createEyebrows(headGroup);
         this.createNose(headGroup);
         this.createMouth(headGroup);
         this.createEars(headGroup);
         this.createHair(headGroup);
         
         // Add human-like details
         this.createFreckles(headGroup);
         this.createDimples(headGroup);
         this.createCheekHighlight(headGroup);
        
        headGroup.position.y = 1.6;
        this.avatarGroup.add(headGroup);
    }
    
    createEyes(headGroup) {
        // Adjust eye positioning based on face shape
        const faceType = this.avatarConfig.face || 'round';
        let eyeSpacing = 0.25;
        let eyeHeight = 0.12;
        let eyeDepth = 0.6;
        
        switch (faceType) {
            case 'oval':
                eyeSpacing = 0.23;
                eyeHeight = 0.15;
                break;
            case 'square':
                eyeSpacing = 0.27;
                eyeHeight = 0.1;
                break;
            case 'heart':
                eyeSpacing = 0.22;
                eyeHeight = 0.18;
                break;
            case 'diamond':
                eyeSpacing = 0.21;
                eyeHeight = 0.2;
                break;
        }
        
        // More subtle eye sockets
        const socketGeometry = new THREE.SphereGeometry(0.15, 16, 16);
        const socketMaterial = new THREE.MeshLambertMaterial({ 
            color: this.darkenColor(this.avatarConfig.skinColor, 8)
        });
        
        // Left eye socket
        const leftSocket = new THREE.Mesh(socketGeometry, socketMaterial);
        leftSocket.position.set(-eyeSpacing, eyeHeight, eyeDepth);
        leftSocket.scale.z = 0.4;
        headGroup.add(leftSocket);
        
        // Right eye socket
        const rightSocket = new THREE.Mesh(socketGeometry, socketMaterial);
        rightSocket.position.set(eyeSpacing, eyeHeight, eyeDepth);
        rightSocket.scale.z = 0.4;
        headGroup.add(rightSocket);
        
        // Eye whites with better proportions
        const scleraGeometry = new THREE.SphereGeometry(0.1, 16, 16);
        const scleraMaterial = new THREE.MeshLambertMaterial({ color: 0xf8f8f8 });
        
        const leftSclera = new THREE.Mesh(scleraGeometry, scleraMaterial);
        leftSclera.position.set(-eyeSpacing, eyeHeight, eyeDepth + 0.08);
        leftSclera.scale.set(1.2, 0.8, 0.6);
        headGroup.add(leftSclera);
        
        const rightSclera = new THREE.Mesh(scleraGeometry, scleraMaterial);
        rightSclera.position.set(eyeSpacing, eyeHeight, eyeDepth + 0.08);
        rightSclera.scale.set(1.2, 0.8, 0.6);
        headGroup.add(rightSclera);
        
        // Iris with more realistic size
        const irisGeometry = new THREE.SphereGeometry(0.045, 16, 16);
        const irisMaterial = new THREE.MeshLambertMaterial({ 
            color: this.avatarConfig.eyeColor 
        });
        
        const leftIris = new THREE.Mesh(irisGeometry, irisMaterial);
        leftIris.position.set(-eyeSpacing, eyeHeight, eyeDepth + 0.12);
        headGroup.add(leftIris);
        
        const rightIris = new THREE.Mesh(irisGeometry, irisMaterial);
        rightIris.position.set(eyeSpacing, eyeHeight, eyeDepth + 0.12);
        headGroup.add(rightIris);
        
        // Pupils
        const pupilGeometry = new THREE.SphereGeometry(0.018, 8, 8);
        const pupilMaterial = new THREE.MeshLambertMaterial({ color: 0x000000 });
        
        const leftPupil = new THREE.Mesh(pupilGeometry, pupilMaterial);
        leftPupil.position.set(-eyeSpacing, eyeHeight, eyeDepth + 0.13);
        headGroup.add(leftPupil);
        
        const rightPupil = new THREE.Mesh(pupilGeometry, pupilMaterial);
        rightPupil.position.set(eyeSpacing, eyeHeight, eyeDepth + 0.13);
        headGroup.add(rightPupil);
        
        // Eye highlights
        const highlightGeometry = new THREE.SphereGeometry(0.008, 8, 8);
        const highlightMaterial = new THREE.MeshLambertMaterial({ color: 0xffffff });
        
        const leftHighlight = new THREE.Mesh(highlightGeometry, highlightMaterial);
        leftHighlight.position.set(-eyeSpacing + 0.01, eyeHeight + 0.01, eyeDepth + 0.135);
        headGroup.add(leftHighlight);
        
        const rightHighlight = new THREE.Mesh(highlightGeometry, highlightMaterial);
        rightHighlight.position.set(eyeSpacing - 0.01, eyeHeight + 0.01, eyeDepth + 0.135);
        headGroup.add(rightHighlight);
        
        // Subtle eyelids
        this.createEyelids(headGroup, eyeSpacing, eyeHeight, eyeDepth);
    }
    
    createEyelids(headGroup, eyeSpacing, eyeHeight, eyeDepth) {
        const eyelidGeometry = new THREE.SphereGeometry(0.11, 16, 8);
        const eyelidMaterial = new THREE.MeshLambertMaterial({ 
            color: this.lightenColor(this.avatarConfig.skinColor, 3)
        });
        
        // Upper eyelids
        const leftUpperEyelid = new THREE.Mesh(eyelidGeometry, eyelidMaterial);
        leftUpperEyelid.position.set(-eyeSpacing, eyeHeight + 0.06, eyeDepth + 0.05);
        leftUpperEyelid.scale.set(1.1, 0.25, 0.7);
        headGroup.add(leftUpperEyelid);
        
        const rightUpperEyelid = new THREE.Mesh(eyelidGeometry, eyelidMaterial);
        rightUpperEyelid.position.set(eyeSpacing, eyeHeight + 0.06, eyeDepth + 0.05);
        rightUpperEyelid.scale.set(1.1, 0.25, 0.7);
        headGroup.add(rightUpperEyelid);
        
        // Lower eyelids (more subtle)
        const leftLowerEyelid = new THREE.Mesh(eyelidGeometry, eyelidMaterial);
        leftLowerEyelid.position.set(-eyeSpacing, eyeHeight - 0.04, eyeDepth + 0.05);
        leftLowerEyelid.scale.set(1.1, 0.15, 0.7);
        headGroup.add(leftLowerEyelid);
        
        const rightLowerEyelid = new THREE.Mesh(eyelidGeometry, eyelidMaterial);
        rightLowerEyelid.position.set(eyeSpacing, eyeHeight - 0.04, eyeDepth + 0.05);
        rightLowerEyelid.scale.set(1.1, 0.15, 0.7);
        headGroup.add(rightLowerEyelid);
    }
    
    createEyebrows(headGroup) {
        const faceType = this.avatarConfig.face || 'round';
        let browSpacing = 0.25;
        let browHeight = 0.28;
        let browWidth = 0.2;
        
        switch (faceType) {
            case 'oval':
                browSpacing = 0.23;
                browHeight = 0.3;
                browWidth = 0.18;
                break;
            case 'square':
                browSpacing = 0.27;
                browHeight = 0.26;
                browWidth = 0.22;
                break;
            case 'heart':
                browSpacing = 0.22;
                browHeight = 0.32;
                browWidth = 0.17;
                break;
            case 'diamond':
                browSpacing = 0.21;
                browHeight = 0.35;
                browWidth = 0.16;
                break;
        }
        
        const eyebrowGeometry = new THREE.BoxGeometry(browWidth, 0.025, 0.05);
        const eyebrowMaterial = new THREE.MeshLambertMaterial({ 
            color: this.avatarConfig.hairColor || this.darkenColor(this.avatarConfig.skinColor, 35)
        });
        
        // Left eyebrow
        const leftEyebrow = new THREE.Mesh(eyebrowGeometry, eyebrowMaterial);
        leftEyebrow.position.set(-browSpacing, browHeight, 0.65);
        leftEyebrow.rotation.z = 0.08;
        headGroup.add(leftEyebrow);
        
        // Right eyebrow
        const rightEyebrow = new THREE.Mesh(eyebrowGeometry, eyebrowMaterial);
        rightEyebrow.position.set(browSpacing, browHeight, 0.65);
        rightEyebrow.rotation.z = -0.08;
        headGroup.add(rightEyebrow);
    }
    
    createNose(headGroup) {
        const faceType = this.avatarConfig.face || 'round';
        const noseType = this.avatarConfig.noseType || 'normal';
        
        // Adjust nose position and size based on face shape
        let noseScale = 1;
        let noseY = -0.02;
        
        switch (faceType) {
            case 'oval':
                noseScale = 0.95;
                noseY = 0.02;
                break;
            case 'square':
                noseScale = 1.05;
                noseY = -0.05;
                break;
            case 'heart':
                noseScale = 0.9;
                noseY = 0.05;
                break;
            case 'diamond':
                noseScale = 0.85;
                noseY = 0.08;
                break;
        }
        
        switch (noseType) {
            case 'button':
                this.createButtonNose(headGroup, noseScale, noseY);
                break;
            case 'aquiline':
                this.createAquilineNose(headGroup, noseScale, noseY);
                break;
            case 'wide':
                this.createWideNose(headGroup, noseScale, noseY);
                break;
            default:
                this.createNormalNose(headGroup, noseScale, noseY);
        }
    }
    
    createNormalNose(headGroup, scale = 1, offsetY = 0) {
        // Nose bridge - more subtle
        const bridgeGeometry = new THREE.BoxGeometry(0.06 * scale, 0.25 * scale, 0.1 * scale);
        const noseMaterial = new THREE.MeshLambertMaterial({ 
            color: this.lightenColor(this.avatarConfig.skinColor, 2)
        });
        
        const bridge = new THREE.Mesh(bridgeGeometry, noseMaterial);
        bridge.position.set(0, 0.02 + offsetY, 0.68);
        headGroup.add(bridge);
        
        // Nose tip - more realistic shape
        const tipGeometry = new THREE.SphereGeometry(0.045 * scale, 16, 16);
        const tip = new THREE.Mesh(tipGeometry, noseMaterial);
        tip.position.set(0, -0.08 + offsetY, 0.72);
        tip.scale.set(1, 0.75, 1.3);
        headGroup.add(tip);
        
        // Nostrils - smaller and more natural
        const nostrilGeometry = new THREE.SphereGeometry(0.012 * scale, 8, 8);
        const nostrilMaterial = new THREE.MeshLambertMaterial({ 
            color: this.darkenColor(this.avatarConfig.skinColor, 20) 
        });
        
        const leftNostril = new THREE.Mesh(nostrilGeometry, nostrilMaterial);
        leftNostril.position.set(-0.02 * scale, -0.09 + offsetY, 0.745);
        leftNostril.scale.set(1, 0.6, 1);
        headGroup.add(leftNostril);
        
        const rightNostril = new THREE.Mesh(nostrilGeometry, nostrilMaterial);
        rightNostril.position.set(0.02 * scale, -0.09 + offsetY, 0.745);
        rightNostril.scale.set(1, 0.6, 1);
        headGroup.add(rightNostril);
    }
    
    createButtonNose(headGroup, scale = 1, offsetY = 0) {
        const noseGeometry = new THREE.SphereGeometry(0.04 * scale, 16, 16);
        const noseMaterial = new THREE.MeshLambertMaterial({ 
            color: this.lightenColor(this.avatarConfig.skinColor, 2)
        });
        
        const nose = new THREE.Mesh(noseGeometry, noseMaterial);
        nose.position.set(0, -0.03 + offsetY, 0.71);
        nose.scale.set(1.1, 0.65, 1.2);
        headGroup.add(nose);
        
        // Small nostrils for button nose
        const nostrilGeometry = new THREE.SphereGeometry(0.008 * scale, 6, 6);
        const nostrilMaterial = new THREE.MeshLambertMaterial({ 
            color: this.darkenColor(this.avatarConfig.skinColor, 25) 
        });
        
        const leftNostril = new THREE.Mesh(nostrilGeometry, nostrilMaterial);
        leftNostril.position.set(-0.015 * scale, -0.05 + offsetY, 0.73);
        headGroup.add(leftNostril);
        
        const rightNostril = new THREE.Mesh(nostrilGeometry, nostrilMaterial);
        rightNostril.position.set(0.015 * scale, -0.05 + offsetY, 0.73);
        headGroup.add(rightNostril);
    }
    
    createAquilineNose(headGroup, scale = 1, offsetY = 0) {
        // Prominent bridge
        const bridgeGeometry = new THREE.CylinderGeometry(0.025 * scale, 0.04 * scale, 0.3 * scale, 8);
        const noseMaterial = new THREE.MeshLambertMaterial({ 
            color: this.lightenColor(this.avatarConfig.skinColor, 2)
        });
        
        const bridge = new THREE.Mesh(bridgeGeometry, noseMaterial);
        bridge.position.set(0, 0.05 + offsetY, 0.69);
        bridge.rotation.x = 0.15;
        headGroup.add(bridge);
        
        // Prominent tip
        const tipGeometry = new THREE.SphereGeometry(0.055 * scale, 16, 16);
        const tip = new THREE.Mesh(tipGeometry, noseMaterial);
        tip.position.set(0, -0.1 + offsetY, 0.73);
        tip.scale.set(0.85, 0.9, 1.4);
        headGroup.add(tip);
    }
    
    createWideNose(headGroup, scale = 1, offsetY = 0) {
        const noseGeometry = new THREE.SphereGeometry(0.055 * scale, 16, 16);
        const noseMaterial = new THREE.MeshLambertMaterial({ 
            color: this.lightenColor(this.avatarConfig.skinColor, 2)
        });
        
        const nose = new THREE.Mesh(noseGeometry, noseMaterial);
        nose.position.set(0, -0.06 + offsetY, 0.7);
        nose.scale.set(1.4, 0.7, 1.1);
        headGroup.add(nose);
        
        // Wider nostrils
        const nostrilGeometry = new THREE.SphereGeometry(0.015 * scale, 8, 8);
        const nostrilMaterial = new THREE.MeshLambertMaterial({ 
            color: this.darkenColor(this.avatarConfig.skinColor, 20) 
        });
        
        const leftNostril = new THREE.Mesh(nostrilGeometry, nostrilMaterial);
        leftNostril.position.set(-0.035 * scale, -0.08 + offsetY, 0.74);
        headGroup.add(leftNostril);
        
        const rightNostril = new THREE.Mesh(nostrilGeometry, nostrilMaterial);
        rightNostril.position.set(0.035 * scale, -0.08 + offsetY, 0.74);
        headGroup.add(rightNostril);
    }
    
    createMouth(headGroup) {
        const faceType = this.avatarConfig.face || 'round';
        const mouthType = this.avatarConfig.mouthType || 'normal';
        
        // Adjust mouth position based on face shape
        let mouthY = -0.25;
        let mouthScale = 1;
        
        switch (faceType) {
            case 'oval':
                mouthY = -0.22;
                mouthScale = 0.95;
                break;
            case 'square':
                mouthY = -0.28;
                mouthScale = 1.05;
                break;
            case 'heart':
                mouthY = -0.2;
                mouthScale = 0.9;
                break;
            case 'diamond':
                mouthY = -0.18;
                mouthScale = 0.85;
                break;
        }
        
        const mouthGroup = new THREE.Group();
        
        switch (mouthType) {
            case 'thin':
                this.createThinLips(mouthGroup, mouthScale);
                break;
            case 'full':
                this.createFullLips(mouthGroup, mouthScale);
                break;
            case 'small':
                this.createSmallMouth(mouthGroup, mouthScale);
                break;
            default:
                this.createNormalMouth(mouthGroup, mouthScale);
        }
        
        mouthGroup.position.set(0, mouthY, 0.65);
        headGroup.add(mouthGroup);
    }
    
    createNormalMouth(mouthGroup, scale = 1) {
        const lipColor = this.avatarConfig.lipColor || this.darkenColor(this.avatarConfig.skinColor, 8);
        
        // Upper lip - more natural curve
        const upperLipGeometry = new THREE.SphereGeometry(0.08 * scale, 16, 8);
        const lipMaterial = new THREE.MeshLambertMaterial({ color: lipColor });
        
        const upperLip = new THREE.Mesh(upperLipGeometry, lipMaterial);
        upperLip.position.set(0, 0.015, 0);
        upperLip.scale.set(1.2, 0.35, 0.7);
        mouthGroup.add(upperLip);
        
        // Lower lip - slightly fuller
        const lowerLipGeometry = new THREE.SphereGeometry(0.08 * scale, 16, 8);
        const lowerLip = new THREE.Mesh(lowerLipGeometry, lipMaterial);
        lowerLip.position.set(0, -0.015, 0);
        lowerLip.scale.set(1.2, 0.4, 0.7);
        mouthGroup.add(lowerLip);
    }
    
    createFullLips(mouthGroup, scale = 1) {
        const lipColor = this.avatarConfig.lipColor || this.darkenColor(this.avatarConfig.skinColor, 12);
        const lipMaterial = new THREE.MeshLambertMaterial({ color: lipColor });
        
        const upperLipGeometry = new THREE.SphereGeometry(0.1 * scale, 16, 8);
        const upperLip = new THREE.Mesh(upperLipGeometry, lipMaterial);
        upperLip.position.set(0, 0.02, 0);
        upperLip.scale.set(1.1, 0.45, 0.8);
        mouthGroup.add(upperLip);
        
        const lowerLipGeometry = new THREE.SphereGeometry(0.1 * scale, 16, 8);
        const lowerLip = new THREE.Mesh(lowerLipGeometry, lipMaterial);
        lowerLip.position.set(0, -0.02, 0);
        lowerLip.scale.set(1.1, 0.55, 0.8);
        mouthGroup.add(lowerLip);
    }
    
    createThinLips(mouthGroup, scale = 1) {
        const lipColor = this.avatarConfig.lipColor || this.lightenColor(this.avatarConfig.skinColor, -5);
        const lipMaterial = new THREE.MeshLambertMaterial({ color: lipColor });
        
        const lipGeometry = new THREE.BoxGeometry(0.12 * scale, 0.02, 0.04);
        const lips = new THREE.Mesh(lipGeometry, lipMaterial);
        lips.position.set(0, 0, 0.02);
        mouthGroup.add(lips);
    }
    
    createSmallMouth(mouthGroup, scale = 1) {
        const lipColor = this.avatarConfig.lipColor || this.darkenColor(this.avatarConfig.skinColor, 6);
        const lipMaterial = new THREE.MeshLambertMaterial({ color: lipColor });
        
        const mouthGeometry = new THREE.SphereGeometry(0.05 * scale, 16, 8);
        const mouth = new THREE.Mesh(mouthGeometry, lipMaterial);
        mouth.scale.set(1, 0.4, 0.7);
        mouthGroup.add(mouth);
    }
    
    createEars(headGroup) {
        const faceType = this.avatarConfig.face || 'round';
        let earPosition = 0.72;
        let earScale = 1;
        
        switch (faceType) {
            case 'oval':
                earPosition = 0.7;
                earScale = 0.95;
                break;
            case 'square':
                earPosition = 0.75;
                earScale = 1.05;
                break;
            case 'heart':
                earPosition = 0.68;
                earScale = 0.9;
                break;
            case 'diamond':
                earPosition = 0.65;
                earScale = 0.85;
                break;
        }
        
        const earGeometry = new THREE.SphereGeometry(0.08 * earScale, 16, 16);
        const earMaterial = new THREE.MeshLambertMaterial({ 
            color: this.lightenColor(this.avatarConfig.skinColor, -2)
        });
        
        // Left ear
        const leftEar = new THREE.Mesh(earGeometry, earMaterial);
        leftEar.position.set(-earPosition, 0.08, -0.02);
        leftEar.scale.set(0.6, 1.2, 0.4);
        leftEar.castShadow = true;
        headGroup.add(leftEar);
        
        // Right ear
        const rightEar = new THREE.Mesh(earGeometry, earMaterial);
        rightEar.position.set(earPosition, 0.08, -0.02);
        rightEar.scale.set(0.6, 1.2, 0.4);
        rightEar.castShadow = true;
        headGroup.add(rightEar);
        
        // Inner ear details
        this.createInnerEar(headGroup, -earPosition + 0.03, earScale);
        this.createInnerEar(headGroup, earPosition - 0.03, earScale);
    }
    
    createInnerEar(headGroup, xPos, scale = 1) {
        const innerEarGeometry = new THREE.SphereGeometry(0.025 * scale, 8, 8);
        const innerEarMaterial = new THREE.MeshLambertMaterial({ 
            color: this.darkenColor(this.avatarConfig.skinColor, 12) 
        });
        
        const innerEar = new THREE.Mesh(innerEarGeometry, innerEarMaterial);
        innerEar.position.set(xPos, 0.08, 0.05);
        innerEar.scale.set(0.9, 1.3, 0.4);
         headGroup.add(innerEar);
     }
     
     createFreckles(headGroup) {
         // Add subtle freckles for more human appearance
         if (Math.random() > 0.7) { // 30% chance of freckles
             const freckleMaterial = new THREE.MeshLambertMaterial({ 
                 color: this.darkenColor(this.avatarConfig.skinColor, 15)
             });
             
             for (let i = 0; i < 8; i++) {
                 const freckle = new THREE.Mesh(
                     new THREE.SphereGeometry(0.008, 6, 6),
                     freckleMaterial
                 );
                 freckle.position.set(
                     (Math.random() - 0.5) * 0.4,
                     (Math.random() - 0.5) * 0.3 + 0.1,
                     (Math.random() - 0.5) * 0.2 + 0.6
                 );
                 freckle.scale.set(1, 0.6, 1);
                 headGroup.add(freckle);
             }
         }
     }
     
     createDimples(headGroup) {
         // Add subtle dimples for more human appearance
         if (Math.random() > 0.8) { // 20% chance of dimples
             const dimpleMaterial = new THREE.MeshLambertMaterial({ 
                 color: this.darkenColor(this.avatarConfig.skinColor, 8)
             });
             
             // Left dimple
             const leftDimple = new THREE.Mesh(
                 new THREE.SphereGeometry(0.012, 8, 8),
                 dimpleMaterial
             );
             leftDimple.position.set(-0.2, -0.15, 0.65);
             leftDimple.scale.set(1, 0.4, 0.8);
             headGroup.add(leftDimple);
             
             // Right dimple
             const rightDimple = new THREE.Mesh(
                 new THREE.SphereGeometry(0.012, 8, 8),
                 dimpleMaterial
             );
             rightDimple.position.set(0.2, -0.15, 0.65);
             rightDimple.scale.set(1, 0.4, 0.8);
             headGroup.add(rightDimple);
         }
     }
     
     createCheekHighlight(headGroup) {
         // Add subtle cheek highlights for more realistic skin
         const highlightMaterial = new THREE.MeshLambertMaterial({ 
             color: this.lightenColor(this.avatarConfig.skinColor, 5),
             transparent: true,
             opacity: 0.3
         });
         
         // Left cheek highlight
         const leftHighlight = new THREE.Mesh(
             new THREE.SphereGeometry(0.08, 12, 12),
             highlightMaterial
         );
         leftHighlight.position.set(-0.25, 0.05, 0.55);
         leftHighlight.scale.set(1, 0.8, 0.6);
         headGroup.add(leftHighlight);
         
         // Right cheek highlight
         const rightHighlight = new THREE.Mesh(
             new THREE.SphereGeometry(0.08, 12, 12),
             highlightMaterial
         );
         rightHighlight.position.set(0.25, 0.05, 0.55);
         rightHighlight.scale.set(1, 0.8, 0.6);
         headGroup.add(rightHighlight);
     }
     
     // Helper functions for color manipulation
    darkenColor(color, amount) {
        const colorObj = new THREE.Color(color);
        return colorObj.multiplyScalar(1 - amount / 100);
    }
    
    lightenColor(color, amount) {
        const colorObj = new THREE.Color(color);
        const white = new THREE.Color(0xffffff);
        return colorObj.lerp(white, amount / 100);
    }
    
    // Hair creation methods remain the same but with improved positioning
    createHair(headGroup) {
        if (this.avatarConfig.hair === 'bald') return;
        
        const hairGroup = new THREE.Group();
        const faceType = this.avatarConfig.face || 'round';
        
        // Adjust hair positioning based on face shape
        let hairOffset = { x: 1, y: 1, z: 1 };
        switch (faceType) {
            case 'oval':
                hairOffset = { x: 0.95, y: 1.05, z: 1 };
                break;
            case 'square':
                hairOffset = { x: 1.05, y: 0.95, z: 1 };
                break;
            case 'heart':
                hairOffset = { x: 0.9, y: 1.1, z: 1 };
                break;
            case 'diamond':
                hairOffset = { x: 0.85, y: 1.15, z: 1 };
                break;
        }
        
        switch (this.avatarConfig.hair) {
            case 'short':
                this.createShortHair(hairGroup, hairOffset);
                break;
            case 'medium':
                this.createMediumHair(hairGroup, hairOffset);
                break;
            case 'long':
                this.createLongHair(hairGroup, hairOffset);
                break;
            case 'curly':
                this.createCurlyHair(hairGroup, hairOffset);
                break;
            case 'wavy':
                this.createWavyHair(hairGroup, hairOffset);
                break;
            case 'braids':
                this.createBraids(hairGroup, hairOffset);
                break;
            case 'ponytail':
                this.createPonytail(hairGroup, hairOffset);
                break;
            case 'buzz':
                this.createBuzzCut(hairGroup, hairOffset);
                break;
            default:
                this.createShortHair(hairGroup, hairOffset);
        }
        
        headGroup.add(hairGroup);
    }
    
     createShortHair(hairGroup, offset = { x: 1, y: 1, z: 1 }) {
         const hairGeometry = new THREE.SphereGeometry(0.60, 32, 32);
         const hairMaterial = new THREE.MeshLambertMaterial({ 
             color: this.avatarConfig.hairColor 
         });
         
         const hair = new THREE.Mesh(hairGeometry, hairMaterial);
         hair.position.y = 0.5;
         hair.scale.set(offset.x, 0.3 * offset.y, offset.z);
         hair.castShadow = true;
         hairGroup.add(hair);
     }
     
     createMediumHair(hairGroup, offset = { x: 1, y: 1, z: 1 }) {
         // Main hair volume
         const hairGeometry = new THREE.SphereGeometry(0.65, 32, 32);
         const hairMaterial = new THREE.MeshLambertMaterial({ 
             color: this.avatarConfig.hairColor 
         });
         
         const hair = new THREE.Mesh(hairGeometry, hairMaterial);
         hair.position.y = 0.1;
         hair.scale.set(1.05 * offset.x, 0.3 * offset.y, 1.05 * offset.z);
         hair.castShadow = true;
         hairGroup.add(hair);
         
         // Hair sides for more natural look
         for (let i = 0; i < 6; i++) {
             const angle = (Math.PI * 2 / 6) * i;
             const sideHair = new THREE.Mesh(
                 new THREE.SphereGeometry(0.15, 16, 16),
                 hairMaterial
             );
             sideHair.position.set(
                 Math.cos(angle) * 0.75,
                 -0.05,
                 Math.sin(angle) * 0.75
             );
             sideHair.scale.set(1, 1.3, 0.7);
             hairGroup.add(sideHair);
         }
     }
     
     createLongHair(hairGroup, offset = { x: 1, y: 1, z: 1 }) {
         // Main hair volume
         const hairGeometry = new THREE.SphereGeometry(0.75, 32, 32);
         const hairMaterial = new THREE.MeshLambertMaterial({ 
             color: this.avatarConfig.hairColor 
         });
         
         const hair = new THREE.Mesh(hairGeometry, hairMaterial);
         hair.position.y = 0.1;
         hair.scale.set(1.05 * offset.x, 0.7 * offset.y, 1.05 * offset.z);
         hair.castShadow = true;
         hairGroup.add(hair);
         
         // Long hair strands
         for (let i = 0; i < 12; i++) {
             const angle = (Math.PI * 2 / 12) * i;
             const hairStrand = new THREE.Mesh(
                 new THREE.CylinderGeometry(0.015, 0.015, 1.0, 8),
                 hairMaterial
             );
             hairStrand.position.set(
                 Math.cos(angle) * 0.7,
                 -0.15,
                 Math.sin(angle) * 0.7
             );
             hairStrand.rotation.z = Math.random() * 0.3 - 0.15;
             hairStrand.castShadow = true;
             hairGroup.add(hairStrand);
         }
     }
     
     createCurlyHair(hairGroup, offset = { x: 1, y: 1, z: 1 }) {
         // Base hair
         this.createShortHair(hairGroup, offset);
         
         // Curls
         for (let i = 0; i < 15; i++) {
             const angle = (Math.PI * 2 / 15) * i;
             const curl = new THREE.Mesh(
                 new THREE.TorusGeometry(0.06, 0.015, 8, 16),
                 new THREE.MeshLambertMaterial({ 
                     color: this.avatarConfig.hairColor 
                 })
             );
             curl.position.set(
                 Math.cos(angle) * 0.7,
                 0.05 + Math.random() * 0.25,
                 Math.sin(angle) * 0.7
             );
             curl.rotation.x = Math.random() * Math.PI;
             curl.rotation.y = Math.random() * Math.PI;
             curl.castShadow = true;
             hairGroup.add(curl);
         }
     }
     
     createWavyHair(hairGroup, offset = { x: 1, y: 1, z: 1 }) {
         // Base hair
         this.createMediumHair(hairGroup, offset);
         
         // Wave strands
         for (let i = 0; i < 8; i++) {
             const angle = (Math.PI * 2 / 8) * i;
             const wave = new THREE.Mesh(
                 new THREE.CylinderGeometry(0.012, 0.012, 0.5, 8),
                 new THREE.MeshLambertMaterial({ 
                     color: this.avatarConfig.hairColor 
                 })
             );
             wave.position.set(
                 Math.cos(angle) * 0.75,
                 -0.05,
                 Math.sin(angle) * 0.75
             );
             wave.rotation.z = Math.sin(angle) * 0.25;
             wave.castShadow = true;
             hairGroup.add(wave);
         }
     }
     
     createBraids(hairGroup, offset = { x: 1, y: 1, z: 1 }) {
         // Base hair
         this.createShortHair(hairGroup, offset);
         
         // Braids
         const braidMaterial = new THREE.MeshLambertMaterial({ 
             color: this.avatarConfig.hairColor 
         });
         
         // Left braid
         const leftBraid = new THREE.Mesh(
             new THREE.CylinderGeometry(0.025, 0.025, 0.7, 8),
             braidMaterial
         );
         leftBraid.position.set(-0.5, -0.25, -0.4);
         leftBraid.rotation.x = 0.2;
         leftBraid.castShadow = true;
         hairGroup.add(leftBraid);
         
         // Right braid
         const rightBraid = new THREE.Mesh(
             new THREE.CylinderGeometry(0.025, 0.025, 0.7, 8),
             braidMaterial
         );
         rightBraid.position.set(0.5, -0.25, -0.4);
         rightBraid.rotation.x = 0.2;
         rightBraid.castShadow = true;
         hairGroup.add(rightBraid);
     }
     
     createPonytail(hairGroup, offset = { x: 1, y: 1, z: 1 }) {
         // Base hair
         this.createShortHair(hairGroup, offset);
         
         // Ponytail
         const ponytailGeometry = new THREE.CylinderGeometry(0.06, 0.05, 0.7, 12);
         const hairMaterial = new THREE.MeshLambertMaterial({ 
             color: this.avatarConfig.hairColor 
         });
         
         const ponytail = new THREE.Mesh(ponytailGeometry, hairMaterial);
         ponytail.position.set(0, -0.15, -0.6);
         ponytail.rotation.x = 0.25;
         ponytail.castShadow = true;
         hairGroup.add(ponytail);
         
         // Hair tie
         const tieGeometry = new THREE.TorusGeometry(0.08, 0.015, 8, 16);
         const tieMaterial = new THREE.MeshLambertMaterial({ color: 0x333333 });
         
         const tie = new THREE.Mesh(tieGeometry, tieMaterial);
         tie.position.set(0, 0.05, -0.5);
         tie.rotation.x = Math.PI / 2;
         hairGroup.add(tie);
     }
     
     createBuzzCut(hairGroup, offset = { x: 1, y: 1, z: 1 }) {
         const hairGeometry = new THREE.SphereGeometry(0.7, 32, 32);
         const hairMaterial = new THREE.MeshLambertMaterial({ 
             color: this.avatarConfig.hairColor,
             transparent: true,
             opacity: 0.85
         });
         
         const hair = new THREE.Mesh(hairGeometry, hairMaterial);
         hair.position.y = 0.05;
         hair.scale.set(offset.x, 0.4 * offset.y, offset.z);
         hairGroup.add(hair);
     }
    
     createBody() {
         // More anatomically correct body proportions
         const bodyGroup = new THREE.Group();
         
         // Torso with more human-like shape
         let torsoGeometry;
         switch (this.avatarConfig.bodyType) {
             case 'slim':
                 torsoGeometry = new THREE.BoxGeometry(0.45, 1.3, 0.25); // thin rectangle
                 break;
             case 'athletic':
                 torsoGeometry = new THREE.BoxGeometry(0.55, 1.3, 0.3); // balanced
                 break;
             case 'curvy':
                 torsoGeometry = new THREE.BoxGeometry(0.65, 1.3, 0.35); // wider
                 break;
             case 'muscular':
                 torsoGeometry = new THREE.BoxGeometry(0.7, 1.3, 0.4); // big chest
                 break;
             default: // average
                 torsoGeometry = new THREE.BoxGeometry(0.55, 1.3, 0.3);
         }
     
         const bodyMaterial = new THREE.MeshLambertMaterial({ 
             color: this.avatarConfig.skinColor 
         });
         
         const torso = new THREE.Mesh(torsoGeometry, bodyMaterial);
         torso.castShadow = true;
         torso.receiveShadow = true;
         bodyGroup.add(torso);
         
         // Add subtle muscle definition for athletic/muscular types
         if (this.avatarConfig.bodyType === 'athletic' || this.avatarConfig.bodyType === 'muscular') {
             this.createMuscleDefinition(bodyGroup);
         }
         
         // Chest/Bust definition for more realism
         if (this.avatarConfig.gender === 'female' || this.avatarConfig.bodyType === 'curvy') {
             this.createChest(bodyGroup);
         }
         
         // Add shoulder definition
         this.createShoulders(bodyGroup);
         
         // Add neck for better connection to head
         this.createNeck(bodyGroup);
         
         bodyGroup.position.y = 0.05;
         this.avatarGroup.add(bodyGroup);
     }
     
     createMuscleDefinition(bodyGroup) {
         const muscleMaterial = new THREE.MeshLambertMaterial({ 
             color: this.lightenColor(this.avatarConfig.skinColor, -3)
         });
         
         // Pecs
         const leftPec = new THREE.Mesh(
             new THREE.SphereGeometry(0.08, 12, 12),
             muscleMaterial
         );
         leftPec.position.set(-0.12, 0.25, 0.2);
         leftPec.scale.set(1, 0.7, 0.8);
         bodyGroup.add(leftPec);
         
         const rightPec = new THREE.Mesh(
             new THREE.SphereGeometry(0.08, 12, 12),
             muscleMaterial
         );
         rightPec.position.set(0.12, 0.25, 0.2);
         rightPec.scale.set(1, 0.7, 0.8);
         bodyGroup.add(rightPec);
         
         // Abs
         for (let i = 0; i < 3; i++) {
             const ab = new THREE.Mesh(
                 new THREE.BoxGeometry(0.15, 0.03, 0.08),
                 muscleMaterial
             );
             ab.position.set(0, 0.1 - (i * 0.08), 0.18);
             bodyGroup.add(ab);
         }
     }
     
     createNeck(bodyGroup) {
         const neckGeometry = new THREE.CylinderGeometry(0.12, 0.15, 0.3, 12);
         const neckMaterial = new THREE.MeshLambertMaterial({ 
             color: this.avatarConfig.skinColor 
         });
         
         const neck = new THREE.Mesh(neckGeometry, neckMaterial);
         neck.position.y = 0.8;
         neck.castShadow = true;
         neck.receiveShadow = true;
         bodyGroup.add(neck);
     }
    
    createChest(bodyGroup) {
        const chestGeometry = new THREE.SphereGeometry(0.15, 16, 16);
        const chestMaterial = new THREE.MeshLambertMaterial({ 
            color: this.avatarConfig.skinColor 
        });
        
        // Left
        const leftChest = new THREE.Mesh(chestGeometry, chestMaterial);
        leftChest.position.set(-0.15, 0.3, 0.25);
        leftChest.scale.set(1, 0.8, 0.7);
        bodyGroup.add(leftChest);
        
        // Right
        const rightChest = new THREE.Mesh(chestGeometry, chestMaterial);
        rightChest.position.set(0.15, 0.3, 0.25);
        rightChest.scale.set(1, 0.8, 0.7);
        bodyGroup.add(rightChest);
    }
    
    createShoulders(bodyGroup) {
        const shoulderGeometry = new THREE.SphereGeometry(0.2, 16, 16);
        const shoulderMaterial = new THREE.MeshLambertMaterial({ 
            color: this.avatarConfig.skinColor 
        });
        
        // Left shoulder
        const leftShoulder = new THREE.Mesh(shoulderGeometry, shoulderMaterial);
        leftShoulder.position.set(-0.5, 0.5, 0);
        leftShoulder.scale.set(1, 0.8, 0.8);
        bodyGroup.add(leftShoulder);
        
        // Right shoulder
        const rightShoulder = new THREE.Mesh(shoulderGeometry, shoulderMaterial);
        rightShoulder.position.set(0.5, 0.5, 0);
        rightShoulder.scale.set(1, 0.8, 0.8);
        bodyGroup.add(rightShoulder);
    }
    
    // Enhanced utility function for better color manipulation
    darkenColor(color, percent) {
        const hex = color.toString(16).replace('#', '');
        const r = Math.max(0, parseInt(hex.substr(0, 2), 16) - (255 * percent / 100));
        const g = Math.max(0, parseInt(hex.substr(2, 2), 16) - (255 * percent / 100));
        const b = Math.max(0, parseInt(hex.substr(4, 2), 16) - (255 * percent / 100));
        return `rgb(${Math.floor(r)}, ${Math.floor(g)}, ${Math.floor(b)})`;
    }
    
    lightenColor(color, percent) {
        const hex = color.toString(16).replace('#', '');
        const r = Math.min(255, parseInt(hex.substr(0, 2), 16) + (255 * percent / 100));
        const g = Math.min(255, parseInt(hex.substr(2, 2), 16) + (255 * percent / 100));
        const b = Math.min(255, parseInt(hex.substr(4, 2), 16) + (255 * percent / 100));
        return `rgb(${Math.floor(r)}, ${Math.floor(g)}, ${Math.floor(b)})`;
    }
    
    // Enhanced arms with better proportions and joint definition
    createArms() {
        const armGroup = new THREE.Group();
    
        // ===== Materials =====
        const armMaterial = new THREE.MeshLambertMaterial({ 
            color: this.avatarConfig.skinColor 
        });
    
        // ===== Upper Arms =====
        const upperArmGeometry = new THREE.CylinderGeometry(0.12, 0.1, 0.6, 12);
    
        // Left upper arm
        const leftUpperArm = new THREE.Mesh(upperArmGeometry, armMaterial);
        leftUpperArm.position.set(-0.6, 0.3, 0);
        leftUpperArm.rotation.z = 0; // keep straight
        leftUpperArm.castShadow = true;
        armGroup.add(leftUpperArm);
    
        // Right upper arm
        const rightUpperArm = new THREE.Mesh(upperArmGeometry, armMaterial);
        rightUpperArm.position.set(0.6, 0.3, 0);
        rightUpperArm.rotation.z = 0; // keep straight
        rightUpperArm.castShadow = true;
        armGroup.add(rightUpperArm);
    
        // ===== Elbows =====
        const elbowGeometry = new THREE.SphereGeometry(0.08, 12, 12);
    
        const leftElbow = new THREE.Mesh(elbowGeometry, armMaterial);
        leftElbow.position.set(-0.6, 0, 0); // just below upper arm
        armGroup.add(leftElbow);
    
        const rightElbow = new THREE.Mesh(elbowGeometry, armMaterial);
        rightElbow.position.set(0.6, 0, 0);
        armGroup.add(rightElbow);
    
        // ===== Forearms =====
        const forearmGeometry = new THREE.CylinderGeometry(0.09, 0.08, 0.55, 12);
    
        const leftForearm = new THREE.Mesh(forearmGeometry, armMaterial);
        leftForearm.position.set(-0.6, -0.35, 0); // aligned under elbow
        leftForearm.rotation.z = 0;
        leftForearm.castShadow = true;
        armGroup.add(leftForearm);
    
        const rightForearm = new THREE.Mesh(forearmGeometry, armMaterial);
        rightForearm.position.set(0.6, -0.35, 0);
        rightForearm.rotation.z = 0;
        rightForearm.castShadow = true;
        armGroup.add(rightForearm);
    
        // ===== Hands =====
        const handGeometry = new THREE.BoxGeometry(0.15, 0.08, 0.2);
    
        const leftHand = new THREE.Mesh(handGeometry, armMaterial);
        leftHand.position.set(-0.6, -0.65, 0); // at end of forearm
        leftHand.castShadow = true;
        armGroup.add(leftHand);
    
        const rightHand = new THREE.Mesh(handGeometry, armMaterial);
        rightHand.position.set(0.6, -0.65, 0);
        rightHand.castShadow = true;
        armGroup.add(rightHand);
    
        // ===== Fingers & Thumbs =====
        this.createFingers(armGroup, -0.6, -0.65, 'left');
        this.createFingers(armGroup, 0.6, -0.65, 'right');
    
        this.createThumbs(armGroup, -0.6, -0.65, 'left');
        this.createThumbs(armGroup, 0.6, -0.65, 'right');
    
        // Add to avatar
        this.avatarGroup.add(armGroup);
    }
    
    
    createFingers(armGroup, handX, handY, side) {
        const fingerGeometry = new THREE.CylinderGeometry(0.015, 0.012, 0.12, 8);
        const fingerMaterial = new THREE.MeshLambertMaterial({ 
            color: this.avatarConfig.skinColor 
        });
        
        for (let i = 0; i < 4; i++) {
            const finger = new THREE.Mesh(fingerGeometry, fingerMaterial);
            const offsetX = side === 'left' ? -0.06 + (i * 0.04) : 0.06 - (i * 0.04);
            finger.position.set(handX + offsetX, handY - 0.06, 0.08);
            finger.rotation.x = Math.PI / 2;
            armGroup.add(finger);
        }
    }
    
    createThumbs(armGroup, handX, handY, side) {
        const thumbGeometry = new THREE.CylinderGeometry(0.018, 0.015, 0.1, 8);
        const thumbMaterial = new THREE.MeshLambertMaterial({ 
            color: this.avatarConfig.skinColor 
        });
        
        const thumb = new THREE.Mesh(thumbGeometry, thumbMaterial);
        const thumbX = side === 'left' ? handX - 0.08 : handX + 0.08;
        thumb.position.set(thumbX, handY - 0.02, 0.05);
        thumb.rotation.z = side === 'left' ? 0.5 : -0.5;
        thumb.rotation.x = Math.PI / 4;
        armGroup.add(thumb);
    }
    
    // Enhanced legs with better proportions and joint definition
    createLegs() {
        const legGroup = new THREE.Group();
        
        // Thighs with muscle definition
        let thighGeometry;
        switch (this.avatarConfig.bodyType) {
            case 'slim':
                thighGeometry = new THREE.CylinderGeometry(0.1, 0.12, 0.8, 12);
                break;
            case 'athletic':
            case 'muscular':
                thighGeometry = new THREE.CylinderGeometry(0.15, 0.16, 0.8, 12);
                break;
            case 'curvy':
                thighGeometry = new THREE.CylinderGeometry(0.16, 0.18, 0.8, 12);
                break;
            default:
                thighGeometry = new THREE.CylinderGeometry(0.12, 0.14, 0.8, 12);
        }
        
        const legMaterial = new THREE.MeshLambertMaterial({ 
            color: this.avatarConfig.skinColor 
        });
        
        // Left thigh
        const leftThigh = new THREE.Mesh(thighGeometry, legMaterial);
        leftThigh.position.set(-0.2, -0.9, 0);
        leftThigh.castShadow = true;
        legGroup.add(leftThigh);
        
        // Right thigh
        const rightThigh = new THREE.Mesh(thighGeometry, legMaterial);
        rightThigh.position.set(0.2, -0.9, 0);
        rightThigh.castShadow = true;
        legGroup.add(rightThigh);
        
        // Knees
        this.createKnees(legGroup);
        
        // Calves
        const calfGeometry = new THREE.CylinderGeometry(0.08, 0.1, 0.7, 12);
        
        // Left calf
        const leftCalf = new THREE.Mesh(calfGeometry, legMaterial);
        leftCalf.position.set(-0.2, -1.8, 0);
        leftCalf.castShadow = true;
        legGroup.add(leftCalf);
        
        // Right calf
        const rightCalf = new THREE.Mesh(calfGeometry, legMaterial);
        rightCalf.position.set(0.2, -1.8, 0);
        rightCalf.castShadow = true;
        legGroup.add(rightCalf);
        
        // Enhanced feet
        this.createFeet(legGroup);
        
        this.avatarGroup.add(legGroup);
    }
    
    createKnees(legGroup) {
        const kneeGeometry = new THREE.SphereGeometry(0.09, 12, 12);
        const kneeMaterial = new THREE.MeshLambertMaterial({ 
            color: this.avatarConfig.skinColor 
        });
        
        // Left knee
        const leftKnee = new THREE.Mesh(kneeGeometry, kneeMaterial);
        leftKnee.position.set(-0.2, -1.3, 0);
        legGroup.add(leftKnee);
        
        // Right knee
        const rightKnee = new THREE.Mesh(kneeGeometry, kneeMaterial);
        rightKnee.position.set(0.2, -1.3, 0);
        legGroup.add(rightKnee);
    }
    
    createFeet(legGroup) {
        // More realistic foot shape
        const footGeometry = new THREE.BoxGeometry(0.25, 0.12, 0.5);
        const footMaterial = new THREE.MeshLambertMaterial({ 
            color: this.avatarConfig.skinColor 
        });
        
        // Left foot
        const leftFoot = new THREE.Mesh(footGeometry, footMaterial);
        leftFoot.position.set(-0.2, -2.2, 0.15);
        leftFoot.castShadow = true;
        legGroup.add(leftFoot);
        
        // Right foot
        const rightFoot = new THREE.Mesh(footGeometry, footMaterial);
        rightFoot.position.set(0.2, -2.2, 0.15);
        rightFoot.castShadow = true;
        legGroup.add(rightFoot);
        
        // Add toes for detail
        this.createToes(legGroup);
    }
    
    createToes(legGroup) {
        const toeGeometry = new THREE.SphereGeometry(0.02, 8, 8);
        const toeMaterial = new THREE.MeshLambertMaterial({ 
            color: this.avatarConfig.skinColor 
        });
        
        // Left foot toes
        for (let i = 0; i < 5; i++) {
            const toe = new THREE.Mesh(toeGeometry, toeMaterial);
            toe.position.set(-0.2 + (i - 2) * 0.03, -2.25, 0.35);
            toe.scale.set(1, 0.8, 1.2);
            legGroup.add(toe);
        }
        
        // Right foot toes
        for (let i = 0; i < 5; i++) {
            const toe = new THREE.Mesh(toeGeometry, toeMaterial);
            toe.position.set(0.2 + (i - 2) * 0.03, -2.25, 0.35);
            toe.scale.set(1, 0.8, 1.2);
            legGroup.add(toe);
        }
     }
     
     createClothing() {
         this.createTop();
         this.createBottom();
         this.createShoes();
     }
     
    createTop() {
    const group = new THREE.Group();

    let innerGeometry, outerGeometry, height, width, depth;

    switch (this.avatarConfig.top) {
        case 't-shirt':
            width = 0.75; height = 1.3; depth = 0.45;
            innerGeometry = new THREE.BoxGeometry(width * 0.1, height, depth * 1.0);
            outerGeometry = new THREE.BoxGeometry(width, height, depth);
            break;

        case 'shirt':
            width = 0.75; height = 1.3; depth = 0.45;
            innerGeometry = new THREE.BoxGeometry(width * 0.2, height, depth * 1.0);
            outerGeometry = new THREE.BoxGeometry(width, height, depth);
            break;

        case 'dress':
            width = 1.0; height = 1.3; depth = 0.45;
            innerGeometry = new THREE.BoxGeometry(width * 0.30, height, depth * 1.0);
            outerGeometry = new THREE.BoxGeometry(width, height, depth);
            break;

        case 'hoodie':
            width = 0.8; height = 1.3; depth = 0.45;
            innerGeometry = new THREE.BoxGeometry(width * 0.1, height, depth * 1.1);
            outerGeometry = new THREE.BoxGeometry(width, height, depth);
            break;

        case 'tank-top':
            width = 0; height = 0; depth = 0;
            innerGeometry = new THREE.BoxGeometry(width * 0.85, height, depth * 0.85);
            outerGeometry = new THREE.BoxGeometry(width, height, depth);
            break;

        default:
            width = 0.75; height = 1.2; depth = 0.45;
            innerGeometry = new THREE.BoxGeometry(width * 0.9, height, depth * 0.9);
            outerGeometry = new THREE.BoxGeometry(width, height, depth);
    }

    // Materials
    const innerMaterial = new THREE.MeshLambertMaterial({
        color: this.avatarConfig.innerColor || 0xffffff
    });
    const outerMaterial = new THREE.MeshLambertMaterial({
        color: this.avatarConfig.topColor
    });

    // Inner Dress
    const innerDress = new THREE.Mesh(innerGeometry, innerMaterial);
    innerDress.position.y = 0.1;
    innerDress.position.z = 0.01;
    group.add(innerDress);

    // Outer Dress
    const outerDress = new THREE.Mesh(outerGeometry, outerMaterial);
    outerDress.position.y = 0.1;
    group.add(outerDress);

    // Collar (two small cylinders near neck)
    const collarGeometry = new THREE.CylinderGeometry(0.1, 0.1, 0.05, 16);
    const collarMaterial = new THREE.MeshLambertMaterial({ color: this.avatarConfig.topColor });

    const leftCollar = new THREE.Mesh(collarGeometry, collarMaterial);
    leftCollar.position.set(-0.18, height / 2 + 0.1, 0.18);
    group.add(leftCollar);

    const rightCollar = new THREE.Mesh(collarGeometry, collarMaterial);
    rightCollar.position.set(0.18, height / 2 + 0.1, 0.18);
    group.add(rightCollar);

    // Arms (vertical cylinders same color as outer dress)
    const armGeometry = new THREE.CylinderGeometry(0.21, 0.21, 1.1, 15);
    const armMaterial = new THREE.MeshLambertMaterial({ color: this.avatarConfig.topColor });

    const leftArm = new THREE.Mesh(armGeometry, armMaterial);
    leftArm.position.set(-width / 1.4, 0.2, 0);
    group.add(leftArm);

    const rightArm = new THREE.Mesh(armGeometry, armMaterial);
    rightArm.position.set(width / 1.4, 0.2, 0);
    group.add(rightArm);

    // Hoodie hood
    if (this.avatarConfig.top === 'hoodie') {
    // Hood geometry (sphere modified to look like hanging cloth)
    const hoodGeometry = new THREE.SphereGeometry(0.55, 16, 16, 0, Math.PI * 2, 0, Math.PI * 0.75);
    const hoodMaterial = new THREE.MeshLambertMaterial({
        color: this.avatarConfig.topColor
    });

    const hood = new THREE.Mesh(hoodGeometry, hoodMaterial);

    // Position: back of the neck
    hood.position.set(0, height / 2 + 0.0, -0.40);

    // Scale to make it look like cloth hanging
    hood.scale.set(0.5, 0.5, 0.5);

    hood.rotation.x = Math.PI * -3.0;
    hood.rotation.y = Math.PI * -4.5;

    hood.castShadow = true;
    hood.receiveShadow = true;

    group.add(hood);
}


    this.avatarGroup.add(group);
}

     
     createBottom() {
        let legGeometry;
        switch (this.avatarConfig.bottom) {
            case 'jeans':
                legGeometry = new THREE.CylinderGeometry(0.2, 0.14, 1.6, 16);
                break;
            case 'shorts':
                legGeometry = new THREE.CylinderGeometry(0.15, 0.12, 0.8, 16);
                break;
            case 'skirt':
                legGeometry = new THREE.CylinderGeometry(0.4, 0.7, 0.8, 16);
                break;
            case 'pants':
                legGeometry = new THREE.CylinderGeometry(0.2, 0.14, 1.6, 16);
                break;
            case 'leggings':
                legGeometry = new THREE.CylinderGeometry(0.2, 0.3, 1.6, 16);
                break;
            default:
                legGeometry = new THREE.CylinderGeometry(0.15, 0.12, 1.8, 16);
        }
    
        const bottomMaterial = new THREE.MeshLambertMaterial({
            color: this.avatarConfig.bottomColor
        });
    
        // Left leg
        const leftLeg = new THREE.Mesh(legGeometry, bottomMaterial);
        leftLeg.position.set(-0.18, -1.4, 0); // move left
        leftLeg.rotation.z = 0.05; // slight outward tilt
        leftLeg.castShadow = true;
        leftLeg.receiveShadow = true;
    
        // Right leg
        const rightLeg = new THREE.Mesh(legGeometry, bottomMaterial);
        rightLeg.position.set(0.18, -1.4, 0); // move right
        rightLeg.rotation.z = -0.05; // slight outward tilt
        rightLeg.castShadow = true;
        rightLeg.receiveShadow = true;
    
        // If skirt, just one geometry
        if (this.avatarConfig.bottom === 'skirt') {
            const skirt = new THREE.Mesh(legGeometry, bottomMaterial);
            skirt.position.y = -0.8;
            skirt.castShadow = true;
            skirt.receiveShadow = true;
            this.avatarGroup.add(skirt);
        } else {
            this.avatarGroup.add(leftLeg);
            this.avatarGroup.add(rightLeg);
        }
    }
     
     createShoes() {
         if (this.avatarConfig.shoes === 'barefoot') return;
         
         let shoeGeometry;
         switch (this.avatarConfig.shoes) {
             case 'sneakers':
                 shoeGeometry = new THREE.BoxGeometry(0.3, 0.25, 0.8);
                 break;
             case 'boots':
                 shoeGeometry = new THREE.BoxGeometry(0.3, 0.20, 0.8);
                 break;
             case 'sandals':
                 shoeGeometry = new THREE.BoxGeometry(0.3, 0.10, 0.8);
                 break;
             case 'heels':
                 shoeGeometry = new THREE.BoxGeometry(0.3, 0.25, 0.8);
                 break;
             default:
                 shoeGeometry = new THREE.BoxGeometry(0.3, 0.20, 0.8);
         }
         
         const shoeMaterial = new THREE.MeshLambertMaterial({ 
             color: this.avatarConfig.shoeColor 
         });
         
         // Left shoe
         const leftShoe = new THREE.Mesh(shoeGeometry, shoeMaterial);
         leftShoe.position.set(-0.2, -2.3, 0.2);
         leftShoe.castShadow = true;
         this.avatarGroup.add(leftShoe);
         
         // Right shoe
         const rightShoe = new THREE.Mesh(shoeGeometry, shoeMaterial);
         rightShoe.position.set(0.2, -2.3, 0.2);
         rightShoe.castShadow = true;
         this.avatarGroup.add(rightShoe);
     }
     
     // Enhanced accessories with more options
     createAccessories() {
        switch (this.avatarConfig.accessories) {
            case 'glasses':
                this.createGlasses();
                break;
            case 'hat':
                this.createHat();
                break;
            case 'beard':
                this.createBeard();
                break;
            case 'earrings':
                this.createEarrings();
                break;
            case 'necklace':
                this.createNecklace();
                break;
            case 'watch':
                this.createWatch();
                break;
        }
     }
     
     createGlasses() {
         const glassGeometry = new THREE.TorusGeometry(0.15, 0.02, 8, 16);
         const glassMaterial = new THREE.MeshLambertMaterial({ 
             color: 0x333333 
         });
         
         // Left lens
         const leftGlass = new THREE.Mesh(glassGeometry, glassMaterial);
         leftGlass.position.set(-0.25, 1.7, 0.8);
         this.avatarGroup.add(leftGlass);
         
         // Right lens
         const rightGlass = new THREE.Mesh(glassGeometry, glassMaterial);
         rightGlass.position.set(0.25, 1.7, 0.8);
         this.avatarGroup.add(rightGlass);
         
         // Bridge
         const bridgeGeometry = new THREE.CylinderGeometry(0.01, 0.01, 0.1, 8);
         const bridge = new THREE.Mesh(bridgeGeometry, glassMaterial);
         bridge.position.set(0, 1.7, 0.8);
         bridge.rotation.z = Math.PI / 2;
         this.avatarGroup.add(bridge);
     }
     
     createHat() {
         const hatGeometry = new THREE.CylinderGeometry(0.6, 0.6, 0.4, 16);
         const hatMaterial = new THREE.MeshLambertMaterial({ 
             color: '#8b4513' 
         });
         
         const hat = new THREE.Mesh(hatGeometry, hatMaterial);
         hat.position.y = 2.1;
         hat.castShadow = true;
         this.avatarGroup.add(hat);
         
         // Hat brim
         const brimGeometry = new THREE.CylinderGeometry(0.8, 0.8, 0.05, 16);
         const brim = new THREE.Mesh(brimGeometry, hatMaterial);
         brim.position.y = 1.9;
         brim.castShadow = true;
         this.avatarGroup.add(brim);
     }
     
     createBeard() {
         const beardGeometry = new THREE.SphereGeometry(0.3, 16, 16);
         const beardMaterial = new THREE.MeshLambertMaterial({ 
             color: this.avatarConfig.hairColor 
         });
         
         const beard = new THREE.Mesh(beardGeometry, beardMaterial);
         beard.position.set(0, 1.2, 0.6);
         beard.scale.y = 0.5;
         beard.scale.z = 0.3;
         this.avatarGroup.add(beard);
     }
     
     createEarrings() {
        const earringGeometry = new THREE.SphereGeometry(0.03, 8, 8);
        const earringMaterial = new THREE.MeshLambertMaterial({ 
            color: this.avatarConfig.earringColor || '#FFD700' 
        });
        
        // Left earring
        const leftEarring = new THREE.Mesh(earringGeometry, earringMaterial);
        leftEarring.position.set(-0.82, 1.4, 0);
        this.avatarGroup.add(leftEarring);
        
        // Right earring
        const rightEarring = new THREE.Mesh(earringGeometry, earringMaterial);
        rightEarring.position.set(0.82, 1.4, 0);
        this.avatarGroup.add(rightEarring);
    }
    
    createNecklace() {
        const necklaceGeometry = new THREE.TorusGeometry(0.35, 0.015, 8, 32);
        const necklaceMaterial = new THREE.MeshLambertMaterial({ 
            color: this.avatarConfig.necklaceColor || '#FFD700' 
        });
        
        const necklace = new THREE.Mesh(necklaceGeometry, necklaceMaterial);
        necklace.position.set(0, 0.8, 0.3);
        necklace.rotation.x = Math.PI / 2;
        this.avatarGroup.add(necklace);
        
        // Pendant
        const pendantGeometry = new THREE.SphereGeometry(0.04, 12, 12);
        const pendant = new THREE.Mesh(pendantGeometry, necklaceMaterial);
        pendant.position.set(0, 0.6, 0.35);
        this.avatarGroup.add(pendant);
    }
    
    createWatch() {
        // Watch band
        const bandGeometry = new THREE.TorusGeometry(0.08, 0.015, 8, 16);
        const bandMaterial = new THREE.MeshLambertMaterial({ 
            color: this.avatarConfig.watchColor || '#8B4513' 
        });
        
        const band = new THREE.Mesh(bandGeometry, bandMaterial);
        band.position.set(0.9, -0.3, 0);
        band.rotation.z = Math.PI / 2;
        this.avatarGroup.add(band);
        
        // Watch face
        const faceGeometry = new THREE.CylinderGeometry(0.05, 0.05, 0.02, 16);
        const faceMaterial = new THREE.MeshLambertMaterial({ 
            color: '#FFFFFF' 
        });
        
        const face = new THREE.Mesh(faceGeometry, faceMaterial);
        face.position.set(0.9, -0.3, 0);
        face.rotation.x = Math.PI / 2;
        this.avatarGroup.add(face);
    }
    
    // Color helper functions
    lightenColor(color, percent) {
        const num = parseInt(color.replace("#", ""), 16);
        const amt = Math.round(2.55 * percent);
        const R = (num >> 16) + amt;
        const G = (num >> 8 & 0x00FF) + amt;
        const B = (num & 0x0000FF) + amt;
        return "#" + (0x1000000 + (R < 255 ? R < 1 ? 0 : R : 255) * 0x10000 +
            (G < 255 ? G < 1 ? 0 : G : 255) * 0x100 +
            (B < 255 ? B < 1 ? 0 : B : 255)).toString(16).slice(1);
    }
    
    darkenColor(color, percent) {
        const num = parseInt(color.replace("#", ""), 16);
        const amt = Math.round(2.55 * percent);
        const R = (num >> 16) - amt;
        const G = (num >> 8 & 0x00FF) - amt;
        const B = (num & 0x0000FF) - amt;
        return "#" + (0x1000000 + (R > 255 ? 255 : R < 0 ? 0 : R) * 0x10000 +
            (G > 255 ? 255 : G < 0 ? 0 : G) * 0x100 +
            (B > 255 ? 255 : B < 0 ? 0 : B)).toString(16).slice(1);
    }
    
    resetCamera() {
        this.camera.position.set(0, 0, 5);
        this.controls.reset();
    }
    
    toggleAutoRotate() {
        this.autoRotate = !this.autoRotate;
        this.controls.autoRotate = this.autoRotate;
        
        const rotateBtn = document.getElementById('rotateBtn');
        rotateBtn.textContent = this.autoRotate ? '⏸️ Stop Rotate' : '🔄 Auto Rotate';
    }
    
    downloadAvatar() {
        // Render the scene to a canvas
        this.renderer.render(this.scene, this.camera);
        
        // Create download link
        const link = document.createElement('a');
        link.download = 'my-3d-avatar.png';
        link.href = this.renderer.domElement.toDataURL();
        link.click();
    }
    
    onWindowResize() {
        const container = document.getElementById('threejs-container');
        this.camera.aspect = container.clientWidth / container.clientHeight;
        this.camera.updateProjectionMatrix();
        this.renderer.setSize(container.clientWidth, container.clientHeight);
    }
    
    animate() {
        requestAnimationFrame(() => this.animate());
        this.controls.update();
        this.renderer.render(this.scene, this.camera);
    }
}

// Initialize the 3D avatar maker when the page loads
document.addEventListener('DOMContentLoaded', () => {
    new ThreeJSAvatarMaker();
});

// Add some interactive features
document.addEventListener('DOMContentLoaded', () => {
    // Add click animation to buttons
    document.querySelectorAll('.option-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            this.style.transform = 'scale(0.95)';
            setTimeout(() => {
                this.style.transform = 'scale(1)';
            }, 150);
        });
    });
    
    // Add keyboard shortcuts
    document.addEventListener('keydown', (e) => {
        if (e.ctrlKey || e.metaKey) {
            switch(e.key) {
                case 's':
                    e.preventDefault();
                    document.getElementById('downloadBtn').click();
                    break;
                case 'r':
                    e.preventDefault();
                    document.getElementById('resetCameraBtn').click();
                    break;
            }
        }
    });
});
