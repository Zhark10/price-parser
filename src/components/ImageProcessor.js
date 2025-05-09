import React, { useState, useEffect, useRef, forwardRef, useImperativeHandle } from 'react';
import { StyleSheet, View } from 'react-native';
import { WebView } from 'react-native-webview';
import { Asset } from 'expo-asset';
import * as FileSystem from 'expo-file-system';

export const ImageProcessor = forwardRef(({ onTesseractInitialized, onProcessingComplete, onError }, ref) => {
  const [html, setHtml] = useState('');
  const [webViewHeight, setWebViewHeight] = useState(1); // Минимальная высота
  const webViewRef = useRef(null);
  
  // Загрузка HTML файла
  useEffect(() => {
    const loadHtmlFile = async () => {
      try {
        const asset = Asset.fromModule(require('../../assets/web/index.html'));
        await asset.downloadAsync();
        
        const dirPath = `${FileSystem.documentDirectory}web`;
        await FileSystem.makeDirectoryAsync(dirPath, { intermediates: true }).catch(() => {});
        
        const filePath = `${dirPath}/index.html`;
        await FileSystem.copyAsync({
          from: asset.localUri || asset.uri,
          to: filePath
        });
        
        const htmlContent = await FileSystem.readAsStringAsync(filePath);
        setHtml(htmlContent);
      } catch (error) {
        console.error('Ошибка загрузки HTML:');
        onError('Не удалось загрузить необходимые файлы.');
      }
    };

    loadHtmlFile();
  }, [onError]);
  
  // Обработка сообщений от WebView
  const handleWebViewMessage = (event) => {
    try {
      const message = JSON.parse(event.nativeEvent.data);
      
      switch (message.type) {
        case 'tesseractInitialized':
          onTesseractInitialized(true);
          break;
          
        case 'recognitionComplete':
          if (message.numbers && message.numbers.length > 0) {
            onProcessingComplete(message.numbers);
          } else {
            onError('На изображении не найдено чисел.');
          }
          break;
          
        case 'error':
          onError(message.message || 'Произошла ошибка при обработке изображения.');
          break;
      }
    } catch (e) {
      console.error('Ошибка обработки сообщения от WebView:');
      onError('Ошибка обработки данных.');
    }
  };
  
  // Метод для обработки изображения
  const processImage = (base64Image) => {
    if (!webViewRef.current) return false;
    
    webViewRef.current.injectJavaScript(`
      (function() {
        const message = ${JSON.stringify({
          type: 'processImage',
          imageData: base64Image
        })};
        window.postMessage(JSON.stringify(message), '*');
        return true;
      })();
    `);
    
    return true;
  };

  // Expose the processImage method to the parent component via ref
  useImperativeHandle(ref, () => ({
    processImage
  }));

  return (
    <View style={{ height: webViewHeight, overflow: 'hidden' }}>
      <WebView
        ref={webViewRef}
        source={{ html }}
        style={styles.webview}
        originWhitelist={['*']}
        javaScriptEnabled={true}
        onMessage={handleWebViewMessage}
        onError={(error) => {
          console.error('WebView error:');
          onError('Ошибка WebView.');
        }}
        onLoad={() => {
          setWebViewHeight(1); // Минимизируем после загрузки
        }}
      />
    </View>
  );
});

const styles = StyleSheet.create({
  webview: {
    width: '100%',
    height: 1 // Минимальная высота
  }
});