import React from 'react';
import {NumbersDisplay} from './NumbersDisplay';
import {CalculatorControls} from './CalculatorControls';

export const ImageViewScreen = ({ 
  imageUri, 
  foundNumbers, 
  activeNumbers, 
  result, 
  onNumberPress, 
  onGoBack, 
  fadeAnim, 
  panResponder, 
  scale, 
  translateX, 
  translateY,
  currentOperation,
  onSetOperation,
  onClear
}) => {
  if (!imageUri) return null;
  
  return (
    <>
      <NumbersDisplay
        imageUri={imageUri}
        numbers={foundNumbers}
        activeNumbers={activeNumbers}
        result={result}
        onNumberPress={onNumberPress}
        onGoBack={onGoBack}
        fadeAnim={fadeAnim}
        panResponder={panResponder}
        scale={scale}
        translateX={translateX}
        translateY={translateY}
      />

      <CalculatorControls
        currentOperation={currentOperation}
        onSetOperation={onSetOperation}
        onClear={onClear}
        showClearButton={activeNumbers.length > 0}
      />
    </>
  );
};