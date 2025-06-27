import React from 'react';
import { Phone, Clock, User, Users } from 'lucide-react';
import { formatRelativeTime, formatAbsoluteTime } from '../utils/dateUtils';
import { Call } from '../types/call';

interface CallInformationProps {
  call: Call;
}

export function CallInformation({ call }: CallInformationProps) {
  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 mb-8">
      <div className="flex items-center space-x-3 mb-6">
        <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
          <Phone className="w-6 h-6 text-blue-600" />
        </div>
        <h2 className="text-xl font-semibold text-gray-900">Call Information</h2>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div>
          <div className="flex items-center space-x-2 mb-2">
            <Clock className="w-4 h-4 text-gray-400" />
            <p className="text-sm text-gray-600">Created</p>
          </div>
          <p 
            className="text-gray-900 font-medium cursor-help"
            title={formatAbsoluteTime(call['created-at'])}
          >
            {formatRelativeTime(call['created-at'])}
          </p>
        </div>

        {call.SENDER && (
          <div>
            <div className="flex items-center space-x-2 mb-2">
              <User className="w-4 h-4 text-gray-400" />
              <p className="text-sm text-gray-600">Sender UID</p>
            </div>
            <p className="text-gray-900 font-mono text-sm">{call.SENDER['sender-uid']}</p>
          </div>
        )}

        {call.SENDER?.recipients && (
          <div className="md:col-span-2">
            <div className="flex items-center space-x-2 mb-2">
              <Users className="w-4 h-4 text-gray-400" />
              <p className="text-sm text-gray-600">Recipients</p>
            </div>
            <div className="space-y-1">
              {call.SENDER.recipients.map((recipient, index) => (
                <p key={index} className="text-gray-900 font-mono text-sm">{recipient}</p>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
} 