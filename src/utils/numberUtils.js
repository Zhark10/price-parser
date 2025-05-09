// Константы для цветов чисел
export const INACTIVE_NUMBER_COLOR = '#616161';
export const ACTIVE_NUMBER_COLOR = '#3b3b3b';

/**
 * Обрабатывает нажатие на число, меняя его статус активности
 * @param {Object} number - Объект числа
 * @param {number} index - Индекс числа в массиве
 * @param {Array} foundNumbers - Массив всех чисел
 * @param {string} currentOperation - Текущая математическая операция
 * @returns {Array} - Обновленный массив чисел
 */
export const handleNumberPress = (number, index, foundNumbers, currentOperation) => {
  const newFoundNumbers = [...foundNumbers];
  const numActive = !number.active;
  
  newFoundNumbers[index] = {
    ...number,
    active: numActive,
    color: numActive ? ACTIVE_NUMBER_COLOR : INACTIVE_NUMBER_COLOR,
    activationTime: numActive ? Date.now() : undefined,
    operationBefore: numActive ? currentOperation : undefined
  };
  
  return newFoundNumbers;
};

/**
 * Получает активные числа из массива всех чисел
 * @param {Array} foundNumbers - Массив всех чисел
 * @returns {Array} - Массив активных чисел
 */
export const getActiveNumbers = (foundNumbers) => {
  return foundNumbers.filter(num => num.active);
};

/**
 * Рассчитывает результат математических операций над активными числами
 * @param {Array} activeNumbers - Массив активных чисел
 * @returns {number} - Результат вычислений
 */
export const calculateResult = (activeNumbers) => {
  if (!activeNumbers || activeNumbers.length === 0) {
    return 0;
  }
  
  // Сортируем числа по времени активации
  const sortedNumbers = [...activeNumbers].sort((a, b) => 
    (a.activationTime || 0) - (b.activationTime || 0)
  );
  
  let result = parseFloat(sortedNumbers[0].value);
  
  for (let i = 1; i < sortedNumbers.length; i++) {
    const num = sortedNumbers[i];
    const operation = num.operationBefore || '+';
    const value = parseFloat(num.value);
    
    switch (operation) {
      case '+': result += value; break;
      case '-': result -= value; break;
      case '*': result *= value; break;
      case '/': result = value !== 0 ? result / value : result; break;
    }
  }
  
  return Number.isInteger(result) ? result : parseFloat(result.toFixed(2));
};

/**
 * Форматирует массив чисел для отображения в виде математического выражения
 * @param {Array} activeNumbers - Массив активных чисел
 * @returns {string} - Строка математического выражения
 */
export const formatExpression = (activeNumbers) => {
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

/**
 * Преобразует распознанные числа из WebView в формат для работы с ними
 * @param {Array} numbers - Массив распознанных чисел
 * @returns {Array} - Массив чисел с добавленными свойствами
 */
export const prepareRecognizedNumbers = (numbers) => {
  return numbers.map(num => ({
    ...num,
    color: INACTIVE_NUMBER_COLOR,
    active: false
  }));
};