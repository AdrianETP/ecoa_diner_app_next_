
export default function Home() {
    const callBackEnd = async () => {
        const response = await fetch("/api/hello")
        const result = await response.json()
        alert("name: " + result.name)
    }
    return (
        <main className='bg-gray-800 h-screen w-screen text-white flex justify-center pt-3'>
            <button onClick={() => callBackEnd()} className="bg-red-300 rounded-md p-2 h-fit">call backend</button>
        </main >
    )
}
