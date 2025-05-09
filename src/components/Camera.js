import React from 'react';
import {StyleSheet, Text, TouchableOpacity, View} from 'react-native';
import {CameraView} from 'expo-camera';
import * as ImagePicker from "expo-image-picker";
import * as FileSystem from 'expo-file-system';

const Camera = ({onCapture, onOpenCalculator, onOpenMenu}) => {
    const cameraRef = React.useRef(null);

    const takePicture = async () => {
        if (!cameraRef.current) return;

        try {
            const photo = await cameraRef.current.takePictureAsync({
                quality: 1,
                base64: true,
                exif: false
            });

            onCapture(photo);
        } catch (error) {
            console.error('Ошибка при съемке фото:');
        }
    };


    const pickImage = async () => {
        let result = await ImagePicker.launchImageLibraryAsync({
            mediaTypes: ['images'],
            allowsEditing: false,
            quality: 1,
            base64: true,
        });

        if (!result.canceled) {
            try {
                // For ImagePicker result, we may need to get base64 if it's not included
                const selectedAsset = result.assets[0];

                if (!selectedAsset.base64) {
                    const base64 = await FileSystem.readAsStringAsync(selectedAsset.uri, {
                        encoding: FileSystem.EncodingType.Base64,
                    });

                    // Create a photo object similar to the one returned by takePictureAsync
                    const photo = {
                        uri: selectedAsset.uri,
                        base64: base64,
                        width: selectedAsset.width,
                        height: selectedAsset.height
                    };

                    onCapture(photo);
                } else {
                    // If base64 is already included, pass it directly
                    onCapture(selectedAsset);
                }
            } catch (error) {
                console.error('Ошибка при обработке выбранного изображения:');
            }
        }
    };

    return (
        <CameraView
            style={styles.camera}
            ref={cameraRef}
            facing={'back'}
        >
            {/* Menu button at the top */}
            <TouchableOpacity 
                style={styles.menuButton} 
                onPress={onOpenMenu}
            >
                <Text style={styles.buttonText}>☰</Text>
            </TouchableOpacity>
            
            <View style={styles.bottomButtonsContainer}>
                {/* Image picker button at bottom left */}
                <TouchableOpacity
                    style={styles.sideButton}
                    onPress={pickImage}
                >
                    <Text style={styles.buttonText}>🖼️</Text>
                </TouchableOpacity>
                
                {/* Capture button in the center */}
                <TouchableOpacity
                    style={styles.captureButton}
                    onPress={takePicture}
                >
                    <View style={styles.captureButtonInner}/>
                </TouchableOpacity>
                
                {/* Calculator button at bottom right */}
                <TouchableOpacity
                    style={styles.sideButton}
                    onPress={onOpenCalculator}
                >
                    <Text style={styles.buttonText}>🧮</Text>
                </TouchableOpacity>
            </View>
        </CameraView>
    );
};

const styles = StyleSheet.create({
    camera: {
        flex: 1
    },
    bottomButtonsContainer: {
        position: 'absolute',
        bottom: 36,
        left: 0,
        right: 0,
        flexDirection: 'row',
        justifyContent: 'space-around',
        alignItems: 'center',
        paddingHorizontal: 20,
    },
    captureButton: {
        width: 70,
        height: 70,
        borderRadius: 35,
        backgroundColor: 'rgba(255, 255, 255, 0.3)',
        justifyContent: 'center',
        alignItems: 'center',
        borderWidth: 2,
        borderColor: 'white',
    },
    captureButtonInner: {
        width: 60,
        height: 60,
        borderRadius: 30,
        backgroundColor: '#fff'
    },
    menuButton: {
        position: 'absolute',
        top: 20,
        left: 20,
        width: 40,
        height: 40,
        borderRadius: 20,
        backgroundColor: 'rgba(0, 0, 0, 0.6)',
        justifyContent: 'center',
        alignItems: 'center',
        zIndex: 10,
    },
    sideButton: {
        width: 50,
        height: 50,
        borderRadius: 25,
        backgroundColor: 'rgba(0, 0, 0, 0.6)',
        justifyContent: 'center',
        alignItems: 'center',
    },
    buttonText: {
        color: '#fff',
        fontSize: 20,
        fontWeight: 'bold'
    }
});

export default Camera;