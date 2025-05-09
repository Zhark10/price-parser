import React from 'react';
import { View, TouchableOpacity, Text, StyleSheet } from 'react-native';
import { CalculatorControls } from './CalculatorControls';

export const CalculatorScreen = ({ 
  currentOperation, 
  onSetOperation, 
  onClear, 
  activeNumbers, 
  onBack 
}) => {
  return (
    <View style={styles.calculatorContainer}>
      <CalculatorControls
        currentOperation={currentOperation}
        onSetOperation={onSetOperation}
        onClear={onClear}
        showClearButton={activeNumbers.length > 0}
      />
      <TouchableOpacity 
        style={styles.backButton}
        onPress={onBack}
      >
        <Text style={styles.backButtonText}>Назад</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  calculatorContainer: {
    flex: 1,
    backgroundColor: '#121212',
    justifyContent: 'center',
    alignItems: 'center',
  },
  backButton: {
    position: 'absolute',
    bottom: 40,
    backgroundColor: '#333',
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 8,
  },
  backButtonText: {
    color: '#fff',
    fontSize: 16,
  }
});