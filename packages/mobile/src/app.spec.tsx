import 'react-native';
import React from 'react';

import { render } from '@testing-library/react-native';

import { App } from './app.component';

it('renders correctly', () => {
  render(<App />);
});
