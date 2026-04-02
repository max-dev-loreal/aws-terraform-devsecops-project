export default function StatusCard({ title, value }) {
    return (
        <div className="bg-zinc-900 p-6 rounded-2xl shadow-lg">
            <h2 className="text-gray-400">{title}</h2>
            <p className="text-xl font-semibold mt-2">{value}</p>
        </div>
    );
}