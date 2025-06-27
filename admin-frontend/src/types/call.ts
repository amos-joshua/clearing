import { CallState } from '../utils/colors';

export interface CallParticipant {
  state: CallState;
}

export interface CallSender extends CallParticipant {
  'sender-uid': string;
  recipients: string[];
}

export interface Call {
  RECEIVER?: CallParticipant;
  SENDER?: CallSender;
  'created-at': string;
} 