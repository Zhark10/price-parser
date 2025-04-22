import React from 'react';
import { WebView } from 'react-native-webview';
import { SafeAreaView, StyleSheet, Platform } from 'react-native';
import { Asset } from 'expo-asset';
import * as FileSystem from 'expo-file-system';

export default function App() {
  const [html, setHtml] = React.useState('');

  React.useEffect(() => {
    const loadHtmlFile = async () => {
      try {
        // Получаем путь к HTML файлу в assets
        const asset = Asset.fromModule(require('./assets/web/index.html'));
        
        // Убеждаемся, что файл загружен
        await asset.downloadAsync();
        
        // Создаем директорию, если её нет
        const dirPath = `${FileSystem.documentDirectory}web`;
        await FileSystem.makeDirectoryAsync(dirPath, { intermediates: true });
        
        // Копируем файл в документы приложения
        const filePath = `${dirPath}/index.html`;
        await FileSystem.copyAsync({
          from: asset.localUri || asset.uri,
          to: filePath
        });
        
        // Читаем содержимое файла
        const htmlContent = await FileSystem.readAsStringAsync(filePath);
        setHtml(htmlContent);
      } catch (error) {
        console.error('Ошибка загрузки HTML:', error);
      }
    };

    loadHtmlFile();
  }, []);

  return (
    <SafeAreaView style={styles.container}>
      <WebView
        source={{ html }}
        style={styles.webview}
        originWhitelist={['*']}
        javaScriptEnabled={true}
        domStorageEnabled={true}
        allowFileAccess={true}
        allowUniversalAccessFromFileURLs={true}
        onError={(syntheticEvent) => {
          const { nativeEvent } = syntheticEvent;
          console.warn('WebView ошибка:', nativeEvent);
        }}
        onMessage={(event) => {
          console.log('Сообщение от WebView:', event.nativeEvent.data);
        }}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    marginTop: Platform.OS === 'android' ? 25 : 0,
  },
  webview: {
    flex: 1,
  },
});
