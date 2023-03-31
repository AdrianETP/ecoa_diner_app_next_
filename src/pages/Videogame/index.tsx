import React, { useEffect } from 'react';

function UnityGame() {
    useEffect(() => {
        const script = document.createElement('script');
        script.src = './../../../public/WEB/Build/UnityLoader.js';
        script.async = true;
        document.body.appendChild(script);

        return () => {
            document.body.removeChild(script);
        };
    }, []);

    return (
        <div className="bg-gray-500 h-screen flex items-center justify-center">
            <iframe
                title="Unity Game"
                src="/WEB/index.html"
                width="100%"
                height="700"
                frameBorder="0"
            />
        </div>
    );
};

export default UnityGame;
