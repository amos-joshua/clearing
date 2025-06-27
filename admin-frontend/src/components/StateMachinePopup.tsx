import React, { useEffect, useState } from 'react';
import ReactMarkdown from 'react-markdown';
import mermaid from 'mermaid';
import remarkGfm from 'remark-gfm';

interface StateMachinePopupProps {
  isOpen: boolean;
  onClose: () => void;
}

interface CodeProps {
  node?: any;
  inline?: boolean;
  className?: string;
  children?: React.ReactNode;
}

export function StateMachinePopup({ isOpen, onClose }: StateMachinePopupProps) {
  const [markdown, setMarkdown] = useState<string>('');

  useEffect(() => {
    if (isOpen) {
      fetch('/call-state-machines.md')
        .then(response => response.text())
        .then(text => {
          setMarkdown(text);
          // Initialize mermaid after markdown is loaded
          mermaid.initialize({
            startOnLoad: true,
            theme: 'default',
            securityLevel: 'loose',
            fontFamily: 'monospace',
            themeVariables: {
              fontFamily: 'monospace',
              fontSize: '16px',
              primaryColor: '#000000',
              primaryTextColor: '#000000',
              primaryBorderColor: '#000000',
              lineColor: '#000000',
              secondaryColor: '#ffffff',
              tertiaryColor: '#ffffff',
            },
          });
        });
    }
  }, [isOpen]);

  useEffect(() => {
    if (isOpen && markdown) {
      // Wait for the DOM to update with the markdown content
      setTimeout(() => {
        mermaid.contentLoaded();
      }, 100);
    }
  }, [isOpen, markdown]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl shadow-lg w-[90vw] h-[90vh] flex flex-col">
        <div className="flex justify-between items-center p-4 border-b">
          <h2 className="text-xl font-semibold text-gray-900">Call State Machines</h2>
          <button
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <div className="flex-1 overflow-auto p-6">
          <div className="prose max-w-none prose-pre:bg-white prose-pre:text-black">
            <ReactMarkdown
              remarkPlugins={[remarkGfm]}
              components={{
                code: ({ node, inline, className, children, ...props }: CodeProps) => {
                  const match = /language-(\w+)/.exec(className || '');
                  if (!inline && match && match[1] === 'mermaid') {
                    return (
                      <div className="mermaid my-4 bg-white">
                        {String(children)}
                      </div>
                    );
                  }
                  return (
                    <code className={className} {...props}>
                      {children}
                    </code>
                  );
                }
              }}
            >
              {markdown}
            </ReactMarkdown>
          </div>
        </div>
      </div>
    </div>
  );
} 