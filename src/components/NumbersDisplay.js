import React, { useEffect, useState } from 'react';
import { StyleSheet, View, Text, TouchableOpacity, Image, Animated, Dimensions } from 'react-native';
import { useImageManipulation } from '../hooks/useImageManipulation';

const INACTIVE_NUMBER_COLOR = '#616161';
const ACTIVE_NUMBER_COLOR = '#3b3b3b';
const { width, height } = Dimensions.get('window');

export const NumbersDisplay = ({
  imageUri,
  numbers,
  activeNumbers,
  result,
  onNumberPress,
  onGoBack,
  fadeAnim
}) => {
  const [imageSize, setImageSize] = useState({ width: width, height: height - 200 });
  const [scaling, setScaling] = useState(1);
  
  // Using the useImageManipulation hook directly in the component
  const { scale, translateX, translateY, panResponder, resetImageManipulation } = useImageManipulation();

  // Calculate image dimensions on mount
  useEffect(() => {
    if (imageUri) {
      Image.getSize(imageUri, (imgWidth, imgHeight) => {
        // Calculate scaling factor for the image
        const screenRatio = (width) / (height - 200);
        const imageRatio = imgWidth / imgHeight;

        let calculatedWidth, calculatedHeight, scaleFactor;

        if (screenRatio > imageRatio) {
          // Height is the limiting factor
          calculatedHeight = height - 200;
          calculatedWidth = imgWidth * (calculatedHeight / imgHeight);
          scaleFactor = calculatedHeight / imgHeight;
        } else {
          // Width is the limiting factor
          calculatedWidth = width;
          calculatedHeight = imgHeight * (calculatedWidth / imgWidth);
          scaleFactor = calculatedWidth / imgWidth;
        }

        setImageSize({ width: calculatedWidth, height: calculatedHeight });
        setScaling(scaleFactor);
      }, (error) => {
        console.error('Error getting image size:', error);
      });
    }
  }, [imageUri]);

  // Формирование строки выражения для отображения
  const getExpressionString = () => {
    if (activeNumbers.length === 0) return '';

    const sortedNumbers = [...activeNumbers].sort((a, b) =>
      (a.activationTime || 0) - (b.activationTime || 0)
    );

    return sortedNumbers.map((num, index) => {
      if (index === 0) return num.value.toString();

      const operation = num.operationBefore || '+';
      const opSymbol = operation === '*' ? '×' : operation === '/' ? '÷' : operation;

      return `${opSymbol}${num.value}`;
    }).join('');
  };

  return (
    <View style={styles.imageOverlay}>
      <View style={styles.expressionContainer}>
        {activeNumbers.length > 0 && (
          <>
            <Text style={styles.expressionText}>{getExpressionString()}</Text>
            <Text style={styles.resultText}>= {result}</Text>
          </>
        )}
      </View>
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: 'transparent' }}>
        <Animated.View
          style={[
            styles.imageContainer,
            {
              opacity: fadeAnim,
              transform: [
                { translateX },
                { translateY },
                { scale }
              ]
            }
          ]}
          {...panResponder.panHandlers}
        >
          <Image
            source={{ uri: imageUri }}
            style={[styles.image, { width: imageSize.width, height: imageSize.height }]}
            resizeMode="contain"
          />

          {numbers.map((number, index) => {
            // Calculate scaled and positioned coordinates
            const scaledX0 = (number.bbox.x0 * scaling * scale) + translateX;
            const scaledY0 = (number.bbox.y0 * scaling * scale) + translateY;
            const scaledWidth = (number.bbox.x1 - number.bbox.x0) * scaling * scale;
            const scaledHeight = (number.bbox.y1 - number.bbox.y0) * scaling * scale;

            return (
              <TouchableOpacity
                key={index}
                style={[
                  styles.numberOverlay,
                  {
                    left: scaledX0,
                    top: scaledY0,
                    width: scaledWidth,
                    height: scaledHeight,
                    backgroundColor: number.active ? ACTIVE_NUMBER_COLOR : 'rgba(97, 97, 97, 0.6)'
                  }
                ]}
                onPress={() => onNumberPress(number, index)}
              >
                <Text style={styles.numberText}>{number.value}</Text>
              </TouchableOpacity>
            );
          })}
        </Animated.View>
      </View>

    </View>
  );
};

const styles = StyleSheet.create({
  imageOverlay: {
    // position: 'relative',
    flex: 1,
    backgroundColor: '#000'
  },
  expressionContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    padding: 16,
    zIndex: 5
  },
  expressionText: {
    color: '#fff',
    fontSize: 16
  },
  resultText: {
    color: '#fff',
    fontSize: 24,
    fontWeight: '500',
    marginTop: 8
  },
  imageContainer: {
    position: 'relative',
    backgroundColor: 'red'
    // justifyContent: 'center',
    // alignItems: 'center'
  },
  image: {

    resizeMode: 'contain'
  },
  numberOverlay: {
    position: 'absolute',
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  numberText: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 14
  },
  backButtonContainer: {
    position: 'absolute',
    left: 16,
    bottom: 16,
    zIndex: 5
  },
  backButton: {
    padding: 10
  },
  backButtonText: {
    color: '#fff',
    fontSize: 16
  }
});