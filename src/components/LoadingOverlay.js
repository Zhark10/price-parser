import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export const LoadingOverlay = ({ visible, message = 'Обработка изображения...' }) => {
  if (!visible) return null;
  
  return (
    <View style={styles.loadingOverlay}>
      <Text style={styles.loadingText}>{message}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  loadingOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 10
  },
  loadingText: {
    color: '#fff',
    fontSize: 18
  }
});