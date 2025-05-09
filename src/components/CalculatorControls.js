import React from 'react';
import { StyleSheet, View, Text, TouchableOpacity } from 'react-native';

export const CalculatorControls = ({ currentOperation, onSetOperation, onClear, showClearButton }) => {
  return (
    <View style={styles.footer}>
      <View style={styles.operationsContainer}>
        <TouchableOpacity 
          style={[styles.operationButton, currentOperation === '+' && styles.activeOperationButton]} 
          onPress={() => onSetOperation('+')}
        >
          <Text style={styles.operationButtonText}>+</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={[styles.operationButton, currentOperation === '-' && styles.activeOperationButton]} 
          onPress={() => onSetOperation('-')}
        >
          <Text style={styles.operationButtonText}>−</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={[styles.operationButton, currentOperation === '*' && styles.activeOperationButton]} 
          onPress={() => onSetOperation('*')}
        >
          <Text style={styles.operationButtonText}>×</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={[styles.operationButton, currentOperation === '/' && styles.activeOperationButton]} 
          onPress={() => onSetOperation('/')}
        >
          <Text style={styles.operationButtonText}>÷</Text>
        </TouchableOpacity>
      </View>
      
      {showClearButton && (
        <TouchableOpacity 
          style={styles.clearButton} 
          onPress={onClear}
        >
          <Text style={styles.clearButtonText}>AC</Text>
        </TouchableOpacity>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  footer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    backgroundColor: 'rgba(0, 0, 0, 0.7)'
  },
  operationsContainer: {
    flexDirection: 'row',
    flex: 1,
    justifyContent: 'center',
    gap: 12
  },
  operationButton: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: '#333',
    justifyContent: 'center',
    alignItems: 'center'
  },
  activeOperationButton: {
    backgroundColor: '#FF9F0A'
  },
  operationButtonText: {
    color: '#fff',
    fontSize: 24
  },
  clearButton: {
    padding: 10,
    position: 'absolute',
    right: 16
  },
  clearButtonText: {
    color: '#FF4D4D',
    fontSize: 16
  }
});