module.exports = {
    "env": {
        "browser": true,
        "es2021": true
    },
    "globals": {
      "react": true
    },
    "extends": [
        "eslint:recommended",
        "plugin:react/recommended"
    ],
    "parser": "@typescript-eslint/parser",
    "parserOptions": {
        "ecmaFeatures": {
            "jsx": true
        },
        "ecmaVersion": 12,
        "sourceType": "module"
    },
    "plugins": [
        "react",
        "@typescript-eslint"
    ],
    "rules": {
    },
    "settings": {
      "react": {
          "pragma": "React",
          "version": "detect"
      }
    }
};
