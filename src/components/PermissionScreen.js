import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export const PermissionScreen = ({ status }) => {
  let message = 'Запрос разрешений камеры...';
  
  if (status === 'denied') {
    message = 'Нет доступа к камере';
  }
  
  return (
    <View style={styles.centeredContainer}>
      <Text style={styles.messageText}>{message}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  centeredContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#000',
    padding: 20
  },
  messageText: {
    color: '#fff',
    fontSize: 18,
    textAlign: 'center'
  }
});