/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import type { PropsWithChildren } from 'react';
import React from 'react';
import { StyleSheet, Text, View } from 'react-native';

type SectionProperties = PropsWithChildren<{
  title: string;
  sectionId?: number;
}>;

export const Section = ({
  children,
  title,
  sectionId,
}: Readonly<SectionProperties>): JSX.Element => {
  return (
    <View style={styles.sectionContainer}>
      <Text
        style={[styles.sectionTitle]}
        testID={sectionId === undefined ? '' : `section-${sectionId}-title`}>
        {title}
      </Text>
      <Text
        style={[styles.sectionDescription]}
        testID={sectionId === undefined ? '' : `section-${sectionId}-text`}>
        {children}
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
  },
});
