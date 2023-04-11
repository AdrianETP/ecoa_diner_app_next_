import React, { useEffect, useState } from 'react';
import Navbar from '@/Components/Navbar';
import { Estudiante } from '@/types';

function UnityGame() {
    const [user, setUser] = useState<Estudiante | null>(null)
    useEffect(() => {
        const script = document.createElement('script');
        script.src = './../../../public/WEB/Build/UnityLoader.js';
        script.async = true;
        document.body.appendChild(script);
        const queryparams = new URLSearchParams(window.location.search)
        const paramsUserString = queryparams.get("user")
        const sessionUserString = window.sessionStorage.getItem("user")
        if (paramsUserString != null && sessionUserString != null) {
            const sessionUserJson = JSON.parse(sessionUserString)
            const paramsUserJson = JSON.parse(paramsUserString)
            if (JSON.stringify(sessionUserJson) == JSON.stringify(paramsUserJson) && "matricula" in paramsUserJson) {
                setUser(paramsUserJson)
            }
        }
        return () => {
            document.body.removeChild(script);
        };
    }, []);

    return (
        <div className='overflow-hidden'>
            <Navbar nombre={user != null ? user.nombre + " " + user.apellidoPaterno + " " + user.apellidoMaterno : ""} />
            <div className="bg-gray-500 flex h-[95vh] overflow-hidden items-center justify-center">
                <iframe className='m-0'
                    title="Unity Game"
                    src={"/WEBgame/index.html?matricula=" + JSON.stringify(user)}
                    width="100%"
                    height="650"
                />
            </div>
        </div>
    );
};

export default UnityGame;
