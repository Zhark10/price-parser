import { useState, useRef } from 'react';
import { PanResponder } from 'react-native';

export const useImageManipulation = () => {
  const [scale, setScale] = useState(1);
  const [translateX, setTranslateX] = useState(0);
  const [translateY, setTranslateY] = useState(0);
  
  // Хранение последних значений для обновления
  const lastScale = useRef(1);
  const lastTranslateX = useRef(0);
  const lastTranslateY = useRef(0);
  
  // Создаем PanResponder для управления жестами
  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponder: () => true,
      onPanResponderGrant: () => {
        lastScale.current = scale;
        lastTranslateX.current = translateX;
        lastTranslateY.current = translateY;
      },
      onPanResponderMove: (evt, gestureState) => {
        // Обработка перемещения изображения
        if (evt.nativeEvent.touches.length === 1) {
          setTranslateX(lastTranslateX.current + gestureState.dx);
          setTranslateY(lastTranslateY.current + gestureState.dy);
        } 
        // Обработка масштабирования (щипок)
        else if (evt.nativeEvent.touches.length === 2) {
          const touch1 = evt.nativeEvent.touches[0];
          const touch2 = evt.nativeEvent.touches[1];
          
          const distance = Math.sqrt(
            Math.pow(touch2.pageX - touch1.pageX, 2) + 
            Math.pow(touch2.pageY - touch1.pageY, 2)
          );
          
          const initialDistance = Math.sqrt(
            Math.pow(touch2.pageX - touch1.pageX - gestureState.dx, 2) + 
            Math.pow(touch2.pageY - touch1.pageY - gestureState.dy, 2)
          );
          
          if (initialDistance > 0) {
            const newScale = distance / initialDistance * lastScale.current;
            setScale(Math.max(0.5, Math.min(3, newScale)));
          }
        }
      },
      onPanResponderRelease: () => {
        // Сохраняем последние значения перемещения и масштаба
        lastScale.current = scale;
        lastTranslateX.current = translateX;
        lastTranslateY.current = translateY;
      },
    })
  ).current;
  
  const resetImageManipulation = () => {
    setScale(1);
    setTranslateX(0);
    setTranslateY(0);
    lastScale.current = 1;
    lastTranslateX.current = 0;
    lastTranslateY.current = 0;
  };
  
  return {
    scale,
    translateX,
    translateY,
    panResponder,
    resetImageManipulation
  };
};