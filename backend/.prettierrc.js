module.exports = {
  // Basic formatting
  semi: true,
  trailingComma: 'es5',
  singleQuote: true,
  doubleQuote: false,
  tabWidth: 2,
  useTabs: false,
  
  // Line length
  printWidth: 100,
  
  // Bracket spacing
  bracketSpacing: true,
  bracketSameLine: false,
  
  // Arrow functions
  arrowParens: 'always',
  
  // End of line
  endOfLine: 'lf',
  
  // Quotes in objects
  quoteProps: 'as-needed',
  
  // JSX (if needed in future)
  jsxSingleQuote: true,
  jsxBracketSameLine: false,
  
  // Embedded languages
  embeddedLanguageFormatting: 'auto',
  
  // HTML whitespace
  htmlWhitespaceSensitivity: 'css',
  
  // Vue files (if needed in future)
  vueIndentScriptAndStyle: false,
  
  // Prose wrap
  proseWrap: 'preserve',
  
  // Override for specific file types
  overrides: [
    {
      files: '*.json',
      options: {
        printWidth: 80,
        tabWidth: 2,
      },
    },
    {
      files: '*.md',
      options: {
        printWidth: 80,
        proseWrap: 'always',
        tabWidth: 2,
      },
    },
    {
      files: '*.yml',
      options: {
        tabWidth: 2,
        singleQuote: false,
      },
    },
    {
      files: '*.yaml',
      options: {
        tabWidth: 2,
        singleQuote: false,
      },
    },
  ],
};