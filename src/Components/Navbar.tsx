import React from 'react'

interface Props {
    nombre: string
}

function Navbar(props: Props) {
    const CerrarSession = () => {
        if (typeof window != "undefined") {
            window.sessionStorage.removeItem("user")
            location.replace("/")
        }
    }
    return (
        <div className='navbar bg-primary flex justify-between pr-10'>
            <img src='/TecLogo.png' className='w-40' />
            <h1 className='text-primary-content text-xl text-center'>{props.nombre}</h1>
            <button className='btn' onClick={() => CerrarSession()}>cerrar sesion</button>
        </div>
    )
}

export default Navbar
