export type CallState =
  | 'IDLE'
  | 'AUTHORIZED'
  | 'CALLING'
  | 'RINGING'
  | 'ONGOING'
  | 'UNANSWERED'
  | 'REJECTED'
  | 'ENDED';

interface StateColor {
  bg: string;
  text: string;
  border?: string;
}

export const STATE_COLORS: Record<CallState, StateColor> = {
  IDLE: {
    bg: 'bg-gray-100',
    text: 'text-gray-800',
    border: 'border-gray-200'
  },
  AUTHORIZED: {
    bg: 'bg-gray-100',
    text: 'text-gray-800',
    border: 'border-gray-200'
  },
  CALLING: {
    bg: 'bg-yellow-100',
    text: 'text-yellow-800',
    border: 'border-yellow-200'
  },
  RINGING: {
    bg: 'bg-orange-100',
    text: 'text-orange-800',
    border: 'border-orange-200'
  },
  ONGOING: {
    bg: 'bg-blue-100',
    text: 'text-blue-800',
    border: 'border-blue-200'
  },
  UNANSWERED: {
    bg: 'bg-green-100',
    text: 'text-green-800',
    border: 'border-green-200'
  },
  REJECTED: {
    bg: 'bg-lime-800',
    text: 'text-lime-200',
    border: 'border-lime-800'
  },
  ENDED: {
    bg: 'bg-green-700',
    text: 'text-white',
    border: 'border-green-600'
  }
};

// Helper function to check if a string is a valid CallState
export function isValidCallState(state: string): state is CallState {
  return state in STATE_COLORS;
}

export function getStateColorClasses(state: CallState): string {
  const colors = STATE_COLORS[state];
  if (!colors) {
    // Fallback for invalid states
    return 'bg-gray-100 text-gray-800 border-gray-200';
  }
  return `${colors.bg} ${colors.text} ${colors.border || ''}`;
}

export function getStateBadgeClasses(state: CallState): string {
  const colors = STATE_COLORS[state];
  if (!colors) {
    // Fallback for invalid states
    return 'px-2 py-1 rounded text-xs font-medium bg-gray-100 text-gray-800';
  }
  return `px-2 py-1 rounded text-xs font-medium ${colors.bg} ${colors.text}`;
} 