import React, { useState } from 'react';
import { getStateColorClasses } from '../utils/colors';
import { Call } from '../types/call';
import { StateMachinePopup } from './StateMachinePopup';

interface StateComparisonProps {
  call: Call;
}

export function StateComparison({ call }: StateComparisonProps) {
  const [isPopupOpen, setIsPopupOpen] = useState(false);

  return (
    <>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        {call.SENDER && (
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Outgoing Call State</h3>
            <div className="text-center">
              <button
                onClick={() => setIsPopupOpen(true)}
                className={`inline-flex px-6 py-3 rounded-lg text-lg font-medium ${getStateColorClasses(call.SENDER.state)} hover:opacity-90 transition-opacity`}
              >
                {call.SENDER.state}
              </button>
            </div>
          </div>
        )}

        {call.RECEIVER && (
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Incoming Call State</h3>
            <div className="text-center">
              <button
                onClick={() => setIsPopupOpen(true)}
                className={`inline-flex px-6 py-3 rounded-lg text-lg font-medium ${getStateColorClasses(call.RECEIVER.state)} hover:opacity-90 transition-opacity`}
              >
                {call.RECEIVER.state}
              </button>
            </div>
          </div>
        )}
      </div>

      <StateMachinePopup
        isOpen={isPopupOpen}
        onClose={() => setIsPopupOpen(false)}
      />
    </>
  );
} 