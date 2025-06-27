export type Environment = 'development' | 'staging' | 'production';

export const getEnvironment = (): Environment => {
    const mode = import.meta.env.MODE;

    switch (mode) {
        case 'development':
            return 'development';
        case 'staging':
            return 'staging';
        case 'production':
            return 'production';
        default:
            // Default to development for unknown modes
            return 'development';
    }
};

export const isDevelopment = (): boolean => {
    return getEnvironment() === 'development';
};

export const isStaging = (): boolean => {
    return getEnvironment() === 'staging';
};

export const isProduction = (): boolean => {
    return getEnvironment() === 'production';
};

export const shouldShowBanner = (): boolean => {
    return !isProduction();
}; 