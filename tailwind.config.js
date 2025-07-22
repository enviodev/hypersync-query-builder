export default {
  content: ['./index.html', './src/**/*.{js,jsx,ts,tsx,res,res.mjs}'],
  safelist: [
    // Layout & Structure
    'min-h-screen', 'bg-gray-50', 'bg-white', 'max-w-7xl', 'mx-auto',
    'px-4', 'sm:px-6', 'lg:px-8', 'py-4', 'py-8', 'py-12', 'px-6',
    'flex', 'flex-1', 'flex-wrap', 'items-center', 'justify-between', 'justify-center',
    'space-x-2', 'space-x-3', 'space-x-4', 'space-x-6', 'space-x-8', 'space-y-2', 'space-y-4', 'space-y-6',
    'grid', 'grid-cols-1', 'lg:grid-cols-3', 'gap-3', 'gap-6',
    'w-full', 'w-4', 'w-5', 'w-6', 'w-8', 'w-12', 'h-4', 'h-5', 'h-6', 'h-8', 'h-12', 'h-16',
    'overflow-y-auto', 'overflow-x-auto', 'overflow-auto',

    // Text & Typography
    'text-xs', 'text-sm', 'text-base', 'text-lg', 'text-xl', 'text-2xl',
    'font-medium', 'font-semibold', 'font-bold', 'font-mono',
    'text-gray-400', 'text-gray-500', 'text-gray-600', 'text-gray-700', 'text-gray-800', 'text-gray-900',
    'text-blue-500', 'text-blue-600', 'text-blue-700', 'text-blue-800', 'text-blue-900',
    'text-red-500', 'text-red-600', 'text-red-700', 'text-red-800',
    'text-green-600', 'text-green-700', 'text-green-800',
    'text-white', 'text-left', 'text-center',

    // Backgrounds & Colors
    'bg-white', 'bg-gray-50', 'bg-gray-100', 'bg-gray-600', 'bg-gray-700',
    'bg-blue-50', 'bg-blue-100', 'bg-blue-600', 'bg-blue-700',
    'bg-green-50', 'bg-green-100', 'bg-green-600', 'bg-green-700',
    'bg-red-50', 'bg-red-100', 'bg-red-600', 'bg-red-700',
    'bg-purple-50', 'bg-purple-100', 'bg-purple-600', 'bg-purple-700',

    // Borders
    'border', 'border-b', 'border-t', 'border-2', 'border-gray-100', 'border-gray-200', 'border-gray-300',
    'border-blue-200', 'border-blue-500', 'border-red-200', 'border-red-500',
    'last:border-b-0', 'rounded', 'rounded-md', 'rounded-lg', 'rounded-full',

    // Buttons & Interactive Elements
    'cursor-pointer', 'hover:bg-gray-50', 'hover:bg-gray-100', 'hover:bg-gray-700',
    'hover:bg-blue-50', 'hover:bg-blue-100', 'hover:bg-blue-700',
    'hover:bg-red-100', 'hover:text-red-700', 'hover:text-red-800',
    'hover:text-gray-700', 'hover:text-blue-700', 'hover:border-gray-300',
    'focus:outline-none', 'focus:ring-1', 'focus:ring-2', 'focus:ring-blue-500',
    'focus:ring-gray-500', 'focus:ring-red-500', 'focus:border-blue-500',
    'disabled:opacity-50',

    // Positioning & Layout
    'relative', 'absolute', 'inset-y-0', 'right-0', 'left-0', 'top-0', 'bottom-0',
    'z-10', 'pointer-events-none',

    // Spacing & Sizing
    'mb-1', 'mb-2', 'mb-3', 'mb-4', 'mb-6', 'mb-8', 'mt-1', 'mt-2', 'mt-4', 'mt-6', 'mt-16',
    'ml-3', 'mr-2', 'p-2', 'p-3', 'p-4', 'p-6', 'pl-3', 'pr-2', 'pr-10',
    'px-2', 'px-2.5', 'px-3', 'px-4', 'py-0.5', 'py-1', 'py-2', 'py-3',
    'max-h-60', 'max-h-64', 'max-h-96', 'min-h-96',

    // Flex & Display
    'inline-flex', 'flex-col', 'inline-block', 'block', 'hidden',

    // Shadows & Effects
    'shadow', 'shadow-sm', 'shadow-lg', 'drop-shadow',

    // Transforms & Animations
    'transform', 'transition-colors', 'transition-transform', 'duration-200',
    'rotate-0', 'rotate-180', 'animate-spin',

    // Form Elements
    'checked:bg-blue-600', 'checked:border-transparent',

    // Specific Component Classes
    'whitespace-pre', 'truncate',

    // State Classes
    'Active', 'Success', 'Error',

    // Dynamic classes that might be generated
    'border-blue-200', 'border-blue-500', 'border-green-200', 'border-green-500',
    'border-purple-200', 'border-purple-500', 'border-red-200', 'border-red-500',
    'text-blue-900', 'text-purple-800', 'text-green-800', 'text-red-800',
    'bg-purple-600', 'bg-green-600',
  ],
}
