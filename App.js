import React, {useEffect, useRef, useState} from 'react';
import {
    Alert,
    Animated,
    Platform,
    SafeAreaView,
    StatusBar,
    StyleSheet
} from 'react-native';
import {useCameraPermissions} from 'expo-camera';

// Импортируем компоненты
import Camera from './src/components/Camera';
import { PermissionScreen } from './src/components/PermissionScreen';
import { CalculatorScreen } from './src/components/CalculatorScreen';
import { ImageViewScreen } from './src/components/ImageViewScreen';
import { LoadingOverlay } from './src/components/LoadingOverlay';
import { ImageProcessor } from "./src/components/ImageProcessor";

// Импортируем хуки и утилиты
import {useImageManipulation} from './src/hooks/useImageManipulation';
import {calculateResult, getActiveNumbers, handleNumberPress, prepareRecognizedNumbers} from './src/utils/numberUtils';

export default function App() {
    // Состояние для WebView и Tesseract
    const [tesseractReady, setTesseractReady] = useState(false);
    const [permission, requestPermission] = useCameraPermissions();
    
    // Состояние активного экрана
    const [activeScreen, setActiveScreen] = useState('camera');
    
    // Состояние меню
    const [menuVisible, setMenuVisible] = useState(false);

    // Состояние распознанных чисел
    const [foundNumbers, setFoundNumbers] = useState([]);
    const [activeNumbers, setActiveNumbers] = useState([]);

    // Состояние калькулятора
    const [currentOperation, setCurrentOperation] = useState('+');
    const [result, setResult] = useState(0);

    // Состояние обработки изображения
    const [imageUri, setImageUri] = useState(null);
    const [isProcessing, setIsProcessing] = useState(false);

    // Анимация
    const fadeAnim = useRef(new Animated.Value(0)).current;

    // Refs
    const imageProcessorRef = useRef(null);

    // Хук для управления масштабированием и перемещением изображения
    const {
        scale,
        translateX,
        translateY,
        panResponder,
        resetImageManipulation
    } = useImageManipulation();

    // Запрос разрешения на использование камеры
    useEffect(() => {
        if (!permission?.granted) {
            requestPermission()
        }
    }, []);

    // Обработчик нажатия на число
    const onNumberPress = (number, index) => {
        const newFoundNumbers = handleNumberPress(number, index, foundNumbers, currentOperation);
        setFoundNumbers(newFoundNumbers);

        // Обновляем список активных чисел
        const newActiveNumbers = getActiveNumbers(newFoundNumbers);
        setActiveNumbers(newActiveNumbers);

        // Пересчитываем результат
        setResult(calculateResult(newActiveNumbers));
    };

    const handleOpenCalculator = () => {
        setActiveScreen('calculator');
    };

    const handleOpenMenu = () => {
        setMenuVisible(true);
        // Здесь можно показать модальное окно меню или другие действия
    };

    // Обработчик после съемки фото
    const handleCapture = (photo) => {
        setActiveScreen('processing');
        setImageUri(photo.uri);
        setIsProcessing(true);

        // Отправляем фото в WebView для обработки
        if (imageProcessorRef.current) {
            imageProcessorRef.current.processImage(photo.base64);
        }
    };

    // Обработчик успешного распознавания чисел
    const handleProcessingComplete = (numbers) => {
        setIsProcessing(false);
        // Подготавливаем числа к отображению
        const preparedNumbers = prepareRecognizedNumbers(numbers);
        setFoundNumbers(preparedNumbers);
        setActiveScreen('imageView');

        // Показываем анимацию после распознавания
        Animated.timing(fadeAnim, {
            toValue: 1,
            duration: 300,
            useNativeDriver: true,
        }).start();
    };

    // Обработчик ошибки
    const handleError = (message) => {
        setIsProcessing(false);
        setActiveScreen('camera');
        Alert.alert('Ошибка', message);
    };

    // Обработчик нажатия на кнопку "Назад"
    const handleGoBack = () => {
        setActiveScreen('camera');
        setFoundNumbers([]);
        setActiveNumbers([]);
        setResult(0);
        setImageUri(null);

        // Сбрасываем масштаб и позицию изображения
        resetImageManipulation();
    };

    // Обработчик возврата к камере из калькулятора
    const handleBackToCamera = () => {
        setActiveScreen('camera');
    };

    // Обработчик смены математической операции
    const handleSetOperation = (operation) => {
        setCurrentOperation(operation);
    };

    // Обработчик очистки выбранных чисел
    const handleClear = () => {
        const resetNumbers = foundNumbers.map(num => ({
            ...num,
            active: false,
            color: '#616161',
            activationTime: undefined,
            operationBefore: undefined
        }));

        setFoundNumbers(resetNumbers);
        setActiveNumbers([]);
        setResult(0);
        setCurrentOperation('+');
    };

    // Проверяем разрешения
    if (!permission) {
        return <PermissionScreen status="loading" />;
    }

    if (!permission.granted) {
        return <PermissionScreen status="denied" />;
    }

    // Функция для рендеринга активного экрана
    const renderActiveScreen = () => {
        switch (activeScreen) {
            case 'camera':
                return (
                    <Camera
                        onCapture={handleCapture}
                        onOpenCalculator={handleOpenCalculator}
                        onOpenMenu={handleOpenMenu}
                    />
                );
            case 'calculator':
                return (
                    <CalculatorScreen
                        currentOperation={currentOperation}
                        onSetOperation={handleSetOperation}
                        onClear={handleClear}
                        activeNumbers={activeNumbers}
                        onBack={handleBackToCamera}
                    />
                );
            case 'imageView':
                return (
                    <ImageViewScreen
                        imageUri={imageUri}
                        foundNumbers={foundNumbers}
                        activeNumbers={activeNumbers}
                        result={result}
                        onNumberPress={onNumberPress}
                        onGoBack={handleGoBack}
                        fadeAnim={fadeAnim}
                        panResponder={panResponder.panHandlers}
                        scale={scale}
                        translateX={translateX}
                        translateY={translateY}
                        currentOperation={currentOperation}
                        onSetOperation={handleSetOperation}
                        onClear={handleClear}
                    />
                );
            default:
                return (
                    <Camera
                        onCapture={handleCapture}
                        onOpenCalculator={handleOpenCalculator}
                        onOpenMenu={handleOpenMenu}
                    />
                );
        }
    };

    return (
        <SafeAreaView style={styles.container}>
            <StatusBar
                barStyle="light-content"
                backgroundColor="#000000"
                translucent={true}
            />

            {/* Скрытый компонент ImageProcessor для обработки изображений */}
            <ImageProcessor
                ref={imageProcessorRef}
                onTesseractInitialized={setTesseractReady}
                onProcessingComplete={handleProcessingComplete}
                onError={handleError}
            />

            {/* Индикатор загрузки */}
            <LoadingOverlay visible={isProcessing} />
            
            {/* Рендеринг активного экрана */}
            {renderActiveScreen()}
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#000',
        paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight : 0
    }
});
