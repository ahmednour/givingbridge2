# Component Library Documentation

## Overview

This document provides comprehensive documentation for all reusable components in the Giving Bridge application. Each component is designed with RTL support, accessibility features, and consistent styling.

## Table of Contents

1. [AppCard](#appcard)
2. [AppButton](#appbutton)
3. [AppTextField](#apptextfield)
4. [AppContainer](#appcontainer)
5. [AppSpacing](#appspacing)
6. [EnhancedDonationCard](#enhanceddonationcard)
7. [DonationFilterWidget](#donationfilterwidget)
8. [DonationSearchBar](#donationsearchbar)
9. [PaginatedList](#paginatedlist)
10. [LazyImage](#lazyimage)
11. [AccessibleButton](#accessiblebutton)
12. [AccessibleTextField](#accessibletextfield)
13. [AccessibleCard](#accessiblecard)

## AppCard

A reusable card component with RTL support and consistent styling.

### Usage

```dart
AppCard(
  child: Text('Card Content'),
  onTap: () => print('Card tapped'),
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.all(8),
  backgroundColor: Colors.white,
  elevation: 2,
  borderRadius: BorderRadius.circular(8),
)
```

### Properties

| Property          | Type            | Default                    | Description                            |
| ----------------- | --------------- | -------------------------- | -------------------------------------- |
| `child`           | `Widget`        | required                   | The content to display inside the card |
| `padding`         | `EdgeInsets?`   | `EdgeInsets.all(16)`       | Internal padding of the card           |
| `margin`          | `EdgeInsets?`   | `EdgeInsets.zero`          | External margin of the card            |
| `backgroundColor` | `Color?`        | `AppTheme.surfaceColor`    | Background color of the card           |
| `elevation`       | `double?`       | `2`                        | Elevation/shadow of the card           |
| `borderRadius`    | `BorderRadius?` | `BorderRadius.circular(8)` | Border radius of the card              |
| `onTap`           | `VoidCallback?` | `null`                     | Callback when the card is tapped       |
| `enableRipple`    | `bool`          | `true`                     | Whether to show ripple effect on tap   |

### Features

- **RTL Support**: Automatically adapts padding and margins for RTL layouts
- **Consistent Styling**: Uses theme colors and spacing constants
- **Tap Handling**: Optional tap handling with ripple effect
- **Customizable**: All visual properties can be customized

### Examples

#### Basic Card

```dart
AppCard(
  child: Text('Hello World'),
)
```

#### Tappable Card

```dart
AppCard(
  onTap: () => Navigator.pushNamed(context, '/details'),
  child: Column(
    children: [
      Icon(Icons.info),
      Text('Tap for details'),
    ],
  ),
)
```

#### Custom Styled Card

```dart
AppCard(
  backgroundColor: Colors.blue.shade50,
  elevation: 4,
  borderRadius: BorderRadius.circular(16),
  child: Text('Custom Card'),
)
```

## AppButton

A comprehensive button component with multiple variants and RTL support.

### Usage

```dart
AppButton(
  text: 'Click Me',
  type: AppButtonType.primary,
  size: AppButtonSize.medium,
  icon: Icons.add,
  onPressed: () => print('Button pressed'),
  isLoading: false,
  isFullWidth: false,
)
```

### Properties

| Property          | Type            | Default                 | Description                               |
| ----------------- | --------------- | ----------------------- | ----------------------------------------- |
| `text`            | `String`        | required                | The text to display on the button         |
| `onPressed`       | `VoidCallback?` | `null`                  | Callback when the button is pressed       |
| `type`            | `AppButtonType` | `AppButtonType.primary` | The visual style of the button            |
| `size`            | `AppButtonSize` | `AppButtonSize.medium`  | The size of the button                    |
| `icon`            | `IconData?`     | `null`                  | Optional icon to display with the text    |
| `isLoading`       | `bool`          | `false`                 | Whether to show loading indicator         |
| `isFullWidth`     | `bool`          | `false`                 | Whether the button should take full width |
| `backgroundColor` | `Color?`        | `null`                  | Custom background color                   |
| `textColor`       | `Color?`        | `null`                  | Custom text color                         |
| `borderRadius`    | `double?`       | `null`                  | Custom border radius                      |

### Button Types

- **Primary**: Elevated button with primary color (default)
- **Secondary**: Outlined button with secondary color
- **Text**: Text button with minimal styling

### Button Sizes

- **Small**: Compact button for tight spaces
- **Medium**: Standard button size (default)
- **Large**: Large button for prominent actions

### Features

- **RTL Support**: Icons and text automatically adapt to RTL layout
- **Loading State**: Shows loading indicator when `isLoading` is true
- **Icon Support**: Optional icon with proper RTL positioning
- **Disabled State**: Automatically handles disabled state when `onPressed` is null
- **Full Width**: Option to make button take full available width

### Examples

#### Primary Button

```dart
AppButton(
  text: 'Submit',
  onPressed: () => submitForm(),
)
```

#### Secondary Button with Icon

```dart
AppButton(
  text: 'Add Item',
  type: AppButtonType.secondary,
  icon: Icons.add,
  onPressed: () => addItem(),
)
```

#### Loading Button

```dart
AppButton(
  text: 'Saving...',
  isLoading: true,
  onPressed: null,
)
```

#### Full Width Button

```dart
AppButton(
  text: 'Continue',
  isFullWidth: true,
  onPressed: () => continueFlow(),
)
```

## AppTextField

A text input component with validation, RTL support, and accessibility features.

### Usage

```dart
AppTextField(
  label: 'Email',
  hint: 'Enter your email',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  validator: (value) => value?.isEmpty == true ? 'Required' : null,
  isRequired: true,
)
```

### Properties

| Property          | Type                          | Default | Description                     |
| ----------------- | ----------------------------- | ------- | ------------------------------- |
| `label`           | `String?`                     | `null`  | Label text for the field        |
| `hint`            | `String?`                     | `null`  | Hint text when field is empty   |
| `helperText`      | `String?`                     | `null`  | Helper text below the field     |
| `errorText`       | `String?`                     | `null`  | Error text to display           |
| `controller`      | `TextEditingController?`      | `null`  | Controller for the text field   |
| `keyboardType`    | `TextInputType?`              | `null`  | Keyboard type for input         |
| `obscureText`     | `bool`                        | `false` | Whether to obscure the text     |
| `enabled`         | `bool`                        | `true`  | Whether the field is enabled    |
| `readOnly`        | `bool`                        | `false` | Whether the field is read-only  |
| `maxLines`        | `int?`                        | `1`     | Maximum number of lines         |
| `maxLength`       | `int?`                        | `null`  | Maximum character length        |
| `prefixIcon`      | `Widget?`                     | `null`  | Icon to display before the text |
| `suffixIcon`      | `Widget?`                     | `null`  | Icon to display after the text  |
| `onTap`           | `VoidCallback?`               | `null`  | Callback when field is tapped   |
| `onChanged`       | `ValueChanged<String>?`       | `null`  | Callback when text changes      |
| `onSubmitted`     | `ValueChanged<String>?`       | `null`  | Callback when text is submitted |
| `validator`       | `FormFieldValidator<String>?` | `null`  | Validation function             |
| `textInputAction` | `TextInputAction?`            | `null`  | Action button on keyboard       |
| `focusNode`       | `FocusNode?`                  | `null`  | Focus node for the field        |
| `isRequired`      | `bool`                        | `false` | Whether the field is required   |

### Features

- **RTL Support**: Text direction and alignment automatically adapt to RTL
- **Validation**: Built-in validation support with error display
- **Accessibility**: Proper semantic labels and hints
- **Customizable**: All visual properties can be customized
- **Required Indicator**: Shows asterisk (\*) for required fields
- **Icon Support**: Prefix and suffix icons with proper positioning

### Examples

#### Basic Text Field

```dart
AppTextField(
  label: 'Name',
  controller: nameController,
)
```

#### Email Field with Validation

```dart
AppTextField(
  label: 'Email',
  hint: 'Enter your email address',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value?.isEmpty == true) return 'Email is required';
    if (!value!.contains('@')) return 'Invalid email format';
    return null;
  },
  isRequired: true,
)
```

#### Password Field

```dart
AppTextField(
  label: 'Password',
  controller: passwordController,
  obscureText: true,
  validator: (value) => value?.length < 6 ? 'Password too short' : null,
)
```

#### Search Field with Icon

```dart
AppTextField(
  hint: 'Search donations...',
  prefixIcon: Icon(Icons.search),
  suffixIcon: Icon(Icons.clear),
  onChanged: (value) => performSearch(value),
)
```

## AppContainer

A flexible container component with RTL-aware styling.

### Usage

```dart
AppContainer(
  child: Text('Container Content'),
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.all(8),
  backgroundColor: Colors.blue,
  borderRadius: BorderRadius.circular(8),
)
```

### Properties

| Property          | Type                 | Default  | Description                                 |
| ----------------- | -------------------- | -------- | ------------------------------------------- |
| `child`           | `Widget`             | required | The content to display inside the container |
| `padding`         | `EdgeInsets?`        | `null`   | Internal padding of the container           |
| `margin`          | `EdgeInsets?`        | `null`   | External margin of the container            |
| `backgroundColor` | `Color?`             | `null`   | Background color of the container           |
| `borderRadius`    | `BorderRadius?`      | `null`   | Border radius of the container              |
| `border`          | `BoxBorder?`         | `null`   | Border around the container                 |
| `boxShadow`       | `List<BoxShadow>?`   | `null`   | Shadow effects for the container            |
| `width`           | `double?`            | `null`   | Width of the container                      |
| `height`          | `double?`            | `null`   | Height of the container                     |
| `alignment`       | `AlignmentGeometry?` | `null`   | Alignment of the child within the container |

### Features

- **Flexible Layout**: Supports all Container properties
- **RTL Support**: Margins and padding adapt to RTL layout
- **Customizable**: All visual properties can be customized
- **Performance**: Optimized for efficient rendering

### Examples

#### Basic Container

```dart
AppContainer(
  child: Text('Hello World'),
)
```

#### Styled Container

```dart
AppContainer(
  padding: EdgeInsets.all(20),
  backgroundColor: Colors.blue.shade50,
  borderRadius: BorderRadius.circular(12),
  child: Text('Styled Container'),
)
```

#### Sized Container

```dart
AppContainer(
  width: 200,
  height: 100,
  alignment: Alignment.center,
  child: Text('Centered Text'),
)
```

## AppSpacing

A utility component for consistent spacing throughout the app.

### Usage

```dart
// Horizontal spacing
AppSpacing.horizontal(20.0)

// Vertical spacing
AppSpacing.vertical(20.0)

// All-around spacing
AppSpacing.all(20.0)

// Custom width and height
AppSpacing(width: 30.0, height: 40.0)
```

### Properties

| Property | Type      | Default | Description                          |
| -------- | --------- | ------- | ------------------------------------ |
| `width`  | `double?` | `null`  | Width of the spacing                 |
| `height` | `double?` | `null`  | Height of the spacing                |
| `all`    | `double?` | `null`  | Same value for both width and height |

### Features

- **Consistent Spacing**: Uses predefined spacing constants
- **RTL Support**: Automatically adapts to RTL layout
- **Performance**: Lightweight SizedBox implementation
- **Flexible**: Supports all spacing scenarios

### Examples

#### Row with Horizontal Spacing

```dart
Row(
  children: [
    Text('Left'),
    AppSpacing.horizontal(20.0),
    Text('Right'),
  ],
)
```

#### Column with Vertical Spacing

```dart
Column(
  children: [
    Text('Top'),
    AppSpacing.vertical(20.0),
    Text('Bottom'),
  ],
)
```

#### All-Around Spacing

```dart
AppSpacing.all(20.0)
```

## EnhancedDonationCard

A specialized card component for displaying donation information with RTL support.

### Usage

```dart
EnhancedDonationCard(
  donation: donation,
  onTap: () => navigateToDetails(donation),
  onRequest: () => requestDonation(donation),
  onEdit: donation.canEdit ? () => editDonation(donation) : null,
  onDelete: donation.canDelete ? () => deleteDonation(donation) : null,
)
```

### Properties

| Property    | Type            | Default  | Description                            |
| ----------- | --------------- | -------- | -------------------------------------- |
| `donation`  | `Donation`      | required | The donation data to display           |
| `onTap`     | `VoidCallback?` | `null`   | Callback when the card is tapped       |
| `onRequest` | `VoidCallback?` | `null`   | Callback when request button is tapped |
| `onEdit`    | `VoidCallback?` | `null`   | Callback when edit button is tapped    |
| `onDelete`  | `VoidCallback?` | `null`   | Callback when delete button is tapped  |

### Features

- **RTL Support**: All content adapts to RTL layout
- **Status Indicators**: Shows donation status with color coding
- **Action Buttons**: Context-aware action buttons
- **Image Support**: Handles image loading and fallbacks
- **Category Tags**: Displays category and condition tags
- **Responsive**: Adapts to different screen sizes

### Examples

#### Basic Donation Card

```dart
EnhancedDonationCard(
  donation: donation,
  onTap: () => showDonationDetails(donation),
)
```

#### Donation Card with Actions

```dart
EnhancedDonationCard(
  donation: donation,
  onTap: () => showDonationDetails(donation),
  onRequest: () => requestDonation(donation),
  onEdit: donation.isOwner ? () => editDonation(donation) : null,
)
```

## DonationFilterWidget

A comprehensive filter widget for donations with RTL support.

### Usage

```dart
DonationFilterWidget(
  onFilterChanged: () => applyFilters(),
  onClearFilters: () => clearAllFilters(),
)
```

### Properties

| Property          | Type            | Default | Description                       |
| ----------------- | --------------- | ------- | --------------------------------- |
| `onFilterChanged` | `VoidCallback?` | `null`  | Callback when filters are changed |
| `onClearFilters`  | `VoidCallback?` | `null`  | Callback when filters are cleared |

### Features

- **Category Filtering**: Filter by donation categories
- **Condition Filtering**: Filter by item condition
- **Status Filtering**: Filter by donation status
- **Availability Filter**: Filter by availability
- **RTL Support**: All filters adapt to RTL layout
- **Clear Filters**: Easy way to clear all filters

### Examples

#### Basic Filter Widget

```dart
DonationFilterWidget(
  onFilterChanged: () => refreshDonations(),
)
```

#### Filter Widget with Clear

```dart
DonationFilterWidget(
  onFilterChanged: () => applyFilters(),
  onClearFilters: () => resetFilters(),
)
```

## DonationSearchBar

A search bar component with filter integration and RTL support.

### Usage

```dart
DonationSearchBar(
  initialQuery: 'food',
  onSearchChanged: (query) => performSearch(query),
  onSearchSubmitted: () => submitSearch(),
)
```

### Properties

| Property            | Type                    | Default | Description                        |
| ------------------- | ----------------------- | ------- | ---------------------------------- |
| `initialQuery`      | `String?`               | `null`  | Initial search query               |
| `onSearchChanged`   | `ValueChanged<String>?` | `null`  | Callback when search query changes |
| `onSearchSubmitted` | `VoidCallback?`         | `null`  | Callback when search is submitted  |

### Features

- **Real-time Search**: Search as you type with debouncing
- **Filter Integration**: Built-in filter button
- **Clear Button**: Easy way to clear search
- **RTL Support**: Proper text direction and alignment
- **Accessibility**: Screen reader support

### Examples

#### Basic Search Bar

```dart
DonationSearchBar(
  onSearchChanged: (query) => searchDonations(query),
)
```

#### Search Bar with Initial Query

```dart
DonationSearchBar(
  initialQuery: 'books',
  onSearchChanged: (query) => searchDonations(query),
  onSearchSubmitted: () => performSearch(),
)
```

## PaginatedList

A performance-optimized list component with pagination and RTL support.

### Usage

```dart
PaginatedList<Donation>(
  items: donations,
  itemBuilder: (context, donation, index) => DonationCard(donation: donation),
  onLoadMore: () => loadMoreDonations(),
  hasMoreData: hasMoreData,
  isLoading: isLoading,
  useGridView: true,
  crossAxisCount: 2,
)
```

### Properties

| Property           | Type                                    | Default  | Description                        |
| ------------------ | --------------------------------------- | -------- | ---------------------------------- |
| `items`            | `List<T>`                               | required | List of items to display           |
| `itemBuilder`      | `Widget Function(BuildContext, T, int)` | required | Builder for each item              |
| `onLoadMore`       | `VoidCallback?`                         | `null`   | Callback to load more items        |
| `hasMoreData`      | `bool`                                  | `false`  | Whether more data is available     |
| `isLoading`        | `bool`                                  | `false`  | Whether data is currently loading  |
| `emptyMessage`     | `String?`                               | `null`   | Message to show when list is empty |
| `emptyWidget`      | `Widget?`                               | `null`   | Widget to show when list is empty  |
| `loadingWidget`    | `Widget?`                               | `null`   | Widget to show while loading       |
| `errorWidget`      | `Widget?`                               | `null`   | Widget to show on error            |
| `errorMessage`     | `String?`                               | `null`   | Error message to display           |
| `onRetry`          | `VoidCallback?`                         | `null`   | Callback to retry on error         |
| `useGridView`      | `bool`                                  | `false`  | Whether to use grid layout         |
| `crossAxisCount`   | `int`                                   | `1`      | Number of columns in grid view     |
| `childAspectRatio` | `double`                                | `1.0`    | Aspect ratio of grid items         |

### Features

- **Lazy Loading**: Loads more items as user scrolls
- **Pull-to-Refresh**: Refresh functionality
- **Error Handling**: Comprehensive error states
- **Empty States**: Proper empty state handling
- **Grid/List Views**: Support for both layouts
- **RTL Support**: Proper RTL layout support

### Examples

#### Basic List

```dart
PaginatedList<Donation>(
  items: donations,
  itemBuilder: (context, donation, index) => DonationCard(donation: donation),
)
```

#### Grid View with Pagination

```dart
PaginatedList<Donation>(
  items: donations,
  itemBuilder: (context, donation, index) => DonationCard(donation: donation),
  onLoadMore: () => loadMoreDonations(),
  hasMoreData: hasMoreData,
  useGridView: true,
  crossAxisCount: 2,
)
```

#### List with Error Handling

```dart
PaginatedList<Donation>(
  items: donations,
  itemBuilder: (context, donation, index) => DonationCard(donation: donation),
  errorMessage: errorMessage,
  onRetry: () => retryLoading(),
)
```

## LazyImage

A performance-optimized image component with lazy loading and RTL support.

### Usage

```dart
LazyImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200,
  height: 150,
  fit: BoxFit.cover,
  placeholder: CircularProgressIndicator(),
  errorWidget: Icon(Icons.broken_image),
)
```

### Properties

| Property       | Type            | Default        | Description                  |
| -------------- | --------------- | -------------- | ---------------------------- |
| `imageUrl`     | `String`        | required       | URL of the image to load     |
| `width`        | `double?`       | `null`         | Width of the image           |
| `height`       | `double?`       | `null`         | Height of the image          |
| `fit`          | `BoxFit`        | `BoxFit.cover` | How the image should fit     |
| `placeholder`  | `Widget?`       | `null`         | Widget to show while loading |
| `errorWidget`  | `Widget?`       | `null`         | Widget to show on error      |
| `borderRadius` | `BorderRadius?` | `null`         | Border radius of the image   |

### Features

- **Lazy Loading**: Loads images only when needed
- **Error Handling**: Graceful error handling with fallback
- **Loading States**: Customizable loading indicators
- **Performance**: Optimized for memory usage
- **RTL Support**: Proper image positioning

### Examples

#### Basic Lazy Image

```dart
LazyImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200,
  height: 150,
)
```

#### Lazy Image with Custom Placeholder

```dart
LazyImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200,
  height: 150,
  placeholder: Container(
    color: Colors.grey.shade200,
    child: Icon(Icons.image),
  ),
)
```

#### Lazy Image with Error Handling

```dart
LazyImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200,
  height: 150,
  errorWidget: Container(
    color: Colors.grey.shade200,
    child: Icon(Icons.broken_image),
  ),
)
```

## AccessibleButton

An accessibility-enhanced button component with ARIA support.

### Usage

```dart
AccessibleButton(
  text: 'Submit',
  semanticLabel: 'Submit form',
  hint: 'Tap to submit the form',
  onPressed: () => submitForm(),
)
```

### Properties

| Property        | Type            | Default                 | Description                               |
| --------------- | --------------- | ----------------------- | ----------------------------------------- |
| `text`          | `String`        | required                | The text to display on the button         |
| `onPressed`     | `VoidCallback?` | `null`                  | Callback when the button is pressed       |
| `semanticLabel` | `String?`       | `null`                  | Semantic label for screen readers         |
| `hint`          | `String?`       | `null`                  | Hint text for screen readers              |
| `type`          | `AppButtonType` | `AppButtonType.primary` | The visual style of the button            |
| `size`          | `AppButtonSize` | `AppButtonSize.medium`  | The size of the button                    |
| `icon`          | `IconData?`     | `null`                  | Optional icon to display                  |
| `isLoading`     | `bool`          | `false`                 | Whether to show loading indicator         |
| `isFullWidth`   | `bool`          | `false`                 | Whether the button should take full width |

### Features

- **ARIA Support**: Proper semantic labels and hints
- **Screen Reader**: Full screen reader compatibility
- **Keyboard Navigation**: Keyboard accessibility
- **Focus Management**: Proper focus handling
- **RTL Support**: RTL layout support

### Examples

#### Accessible Primary Button

```dart
AccessibleButton(
  text: 'Submit',
  semanticLabel: 'Submit form',
  hint: 'Tap to submit the form',
  onPressed: () => submitForm(),
)
```

#### Accessible Button with Icon

```dart
AccessibleButton(
  text: 'Add Item',
  semanticLabel: 'Add new item',
  hint: 'Tap to add a new item to the list',
  icon: Icons.add,
  onPressed: () => addItem(),
)
```

## AccessibleTextField

An accessibility-enhanced text field component with ARIA support.

### Usage

```dart
AccessibleTextField(
  label: 'Email',
  hint: 'Enter your email address',
  semanticLabel: 'Email address field',
  controller: emailController,
  validator: (value) => value?.isEmpty == true ? 'Required' : null,
)
```

### Properties

| Property        | Type                          | Default | Description                       |
| --------------- | ----------------------------- | ------- | --------------------------------- |
| `label`         | `String?`                     | `null`  | Label text for the field          |
| `hint`          | `String?`                     | `null`  | Hint text when field is empty     |
| `semanticLabel` | `String?`                     | `null`  | Semantic label for screen readers |
| `controller`    | `TextEditingController?`      | `null`  | Controller for the text field     |
| `validator`     | `FormFieldValidator<String>?` | `null`  | Validation function               |
| `isRequired`    | `bool`                        | `false` | Whether the field is required     |
| `keyboardType`  | `TextInputType?`              | `null`  | Keyboard type for input           |
| `obscureText`   | `bool`                        | `false` | Whether to obscure the text       |

### Features

- **ARIA Support**: Proper semantic labels and hints
- **Screen Reader**: Full screen reader compatibility
- **Keyboard Navigation**: Keyboard accessibility
- **Focus Management**: Proper focus handling
- **RTL Support**: RTL layout support
- **Validation**: Built-in validation support

### Examples

#### Accessible Email Field

```dart
AccessibleTextField(
  label: 'Email',
  hint: 'Enter your email address',
  semanticLabel: 'Email address field',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  validator: (value) => value?.isEmpty == true ? 'Required' : null,
)
```

#### Accessible Password Field

```dart
AccessibleTextField(
  label: 'Password',
  hint: 'Enter your password',
  semanticLabel: 'Password field',
  controller: passwordController,
  obscureText: true,
  validator: (value) => value?.length < 6 ? 'Too short' : null,
)
```

## AccessibleCard

An accessibility-enhanced card component with ARIA support.

### Usage

```dart
AccessibleCard(
  semanticLabel: 'Donation card',
  hint: 'Tap to view donation details',
  onTap: () => showDonationDetails(donation),
  child: DonationContent(donation: donation),
)
```

### Properties

| Property          | Type            | Default  | Description                            |
| ----------------- | --------------- | -------- | -------------------------------------- |
| `child`           | `Widget`        | required | The content to display inside the card |
| `semanticLabel`   | `String?`       | `null`   | Semantic label for screen readers      |
| `hint`            | `String?`       | `null`   | Hint text for screen readers           |
| `onTap`           | `VoidCallback?` | `null`   | Callback when the card is tapped       |
| `padding`         | `EdgeInsets?`   | `null`   | Internal padding of the card           |
| `margin`          | `EdgeInsets?`   | `null`   | External margin of the card            |
| `backgroundColor` | `Color?`        | `null`   | Background color of the card           |
| `elevation`       | `double?`       | `null`   | Elevation/shadow of the card           |
| `borderRadius`    | `BorderRadius?` | `null`   | Border radius of the card              |

### Features

- **ARIA Support**: Proper semantic labels and hints
- **Screen Reader**: Full screen reader compatibility
- **Keyboard Navigation**: Keyboard accessibility
- **Focus Management**: Proper focus handling
- **RTL Support**: RTL layout support
- **Tap Handling**: Accessible tap handling

### Examples

#### Accessible Donation Card

```dart
AccessibleCard(
  semanticLabel: 'Donation card for ${donation.title}',
  hint: 'Tap to view donation details',
  onTap: () => showDonationDetails(donation),
  child: DonationContent(donation: donation),
)
```

#### Accessible Info Card

```dart
AccessibleCard(
  semanticLabel: 'Information card',
  hint: 'Tap to expand information',
  onTap: () => expandInfo(),
  child: InfoContent(),
)
```

## Best Practices

### 1. RTL Support

- Always use `RTLUtils` for directional properties
- Test components in both LTR and RTL modes
- Use semantic properties instead of hardcoded directions

### 2. Accessibility

- Always provide semantic labels and hints
- Test with screen readers
- Ensure keyboard navigation works
- Use proper focus management

### 3. Performance

- Use `LazyImage` for images
- Implement pagination for large lists
- Use `const` constructors where possible
- Avoid unnecessary rebuilds

### 4. Consistency

- Use theme colors and spacing constants
- Follow naming conventions
- Maintain consistent API across components
- Document all public properties

### 5. Testing

- Write unit tests for all components
- Test RTL and LTR layouts
- Test accessibility features
- Test error states and edge cases

## Conclusion

This component library provides a comprehensive set of reusable UI components for the Giving Bridge application. Each component is designed with RTL support, accessibility features, and consistent styling to ensure a great user experience across all devices and user needs.

The components follow Flutter best practices and are optimized for performance and maintainability. They provide a solid foundation for building the application's user interface while ensuring consistency and accessibility throughout the app.
