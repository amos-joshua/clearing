export function formatRelativeTime(timestamp: string): string {
  const now = new Date();
  const date = new Date(timestamp);
  const diffMs = now.getTime() - date.getTime();
  const diffSec = Math.floor(diffMs / 1000);
  const diffMin = Math.floor(diffSec / 60);
  const diffHour = Math.floor(diffMin / 60);
  const diffDay = Math.floor(diffHour / 24);

  if (diffSec < 10) return 'now';
  if (diffSec < 60) return `${diffSec} seconds ago`;
  if (diffMin === 1) return '1 minute ago';
  if (diffMin < 60) return `${diffMin} minutes ago`;
  if (diffHour === 1) return '1 hour ago';
  if (diffHour < 24) return `${diffHour} hours ago`;
  if (diffDay === 1) return 'yesterday';
  if (diffDay < 7) return `${diffDay} days ago`;
  
  return date.toLocaleDateString();
}

export function formatAbsoluteTime(timestamp: string): string {
  try {
    // Validate input
    if (!timestamp) {
      console.warn('formatAbsoluteTime: Received empty or null timestamp');
      return 'Invalid date';
    }

    // Attempt to parse the date
    const date = new Date(timestamp);
    
    // Check if the date is valid
    if (isNaN(date.getTime())) {
      console.warn(`formatAbsoluteTime: Invalid timestamp format received: ${timestamp}`);
      return 'Invalid date';
    }

    return date.toISOString().replace('T', ' ').slice(0, 19);
  } catch (error) {
    console.error('formatAbsoluteTime: Error formatting date:', error);
    return 'Invalid date';
  }
}